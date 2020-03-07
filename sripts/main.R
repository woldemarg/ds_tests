library(tidyverse)
library(lubridate)
library(geosphere)
library(randomForest)
library(glmnet)
library(fastDummies)



description <- read_csv("data/encoded/columns_description.csv")
events <- read_csv("data/encoded/events_Hokkaido.csv")
holidays <- read_csv("data/encoded/holidays_Japan.csv")
jalan <- read_csv("data/encoded/jalan_shinchitose.csv")
rakuten <- read_csv("data/encoded/rakuten_shinchitose.csv")
weather <- read_csv("data/encoded/weather_Hokkaido.csv")

names(rakuten) <- description$`Row(EN)`[1:48]
names(jalan) <- description$`Row(EN)`[49:94]

#parsing dates
get_date <- function(timestamp, format = "Y/m/d H:M") {
  return(date(parse_date_time(timestamp, format)))
}

holidays <- holidays %>%
  mutate(day = get_date(day, "Y/m/d"))

events <- events %>%
  mutate(
    start_date = get_date(start_date, "Y/m/d"),
    end_date = get_date(end_date, "Y/m/d"),
  )

weather <- weather %>%
  mutate(date = get_date(date, "Y/m/d"))



#detect identical columns within datasets
jalan_filtered <- jalan %>%
  mutate(
    company_name = "jalan",
    request_date = get_date(request_date_time),
    pickup_date = get_date(pickup_date_time),
    return_date = get_date(return_date_time),
    cancellation_date = get_date(cancellation_date_time),
    is_cancelled = ifelse(!is.na(cancellation_date_time), 1, 0),
    #num_of_passengers = as.numeric(str_extract_all(number_of_passengers, "\\d+")[[1]][1]),
    #num_of_children = as.numeric(str_extract_all(number_of_passengers, "\\d+")[[1]][2])
  ) %>%
  select(
    company_name,
    request_date,
    pickup_date,
    return_date,
    request_date,
    cancellation_date,
    is_cancelled,
    #num_of_passengers,
    #num_of_children,
    #arrival_flight,
    #total_price
  )

rakuten_filtered <- rakuten %>%
  mutate(
    company_name = "rakuten",
    request_date = get_date(request_date_time),
    pickup_date = get_date(pickup_date_time),
    return_date = get_date(return_date_time),
    cancellation_date = get_date(cancel_request_date_time),
    is_cancelled = ifelse(!is.na(cancel_request_date_time), 1, 0),
  ) %>%
  # rename(
  #   car_class = company_car_class_code,
  #   num_of_passengers = number_of_passengers,
  #   num_of_children = number_of_children,
  #   arrival_flight = flight_number,
  #   total_price = taxable_amount
  # ) %>%
  select(
    company_name,
    request_date,
    pickup_date,
    return_date,
    request_date,
    cancellation_date,
    is_cancelled,
    #num_of_passengers,
    #num_of_children,
    #arrival_flight,
    #total_price
  )


df_joined <- bind_rows(jalan_filtered, rakuten_filtered)
#df_joined$arrival_flight[df_joined$arrival_flight == "0"] <- NA


#preparing data
model_data <- df_joined %>%
  filter(is_cancelled == 0) %>%
  group_by(pickup_date, company_name) %>%
  summarise(target = n()) %>%
  ungroup() %>%
  pivot_wider(names_from = pickup_date, values_from = target) %>%
  pivot_longer(names(.)[-1],
               names_to = "pickup_date",
               values_to = "target") %>%
  select(target, everything())

model_data[is.na(model_data)] <- 0
model_data$pickup_date <- as_date(model_data$pickup_date)
model_data$company_name <- as_factor(model_data$company_name)


ggplot(data = model_data, aes(x = pickup_date, y = target)) +
  geom_bar(stat = "identity")


#simple average approach
get_cv_rmse_mean_model <- function(data,
                                   k = 10,
                                   seed = 1) {
  set.seed(seed)
  
  data <- data %>%
    mutate(dow = as.character(wday(pickup_date, label = TRUE)),
           mon = month(pickup_date)) %>%
    select(-pickup_date)
  
  data <- data[sample(nrow(data)), ]
  folds <- cut(seq(1, nrow(data)), breaks = k, labels = FALSE)
  rmse <- c()
  
  for (i in 1:k) {
    indices <- which(folds == i, arr.ind = TRUE)
    test_data <- data[indices, ]
    train_data <- data[-indices, ]
    
    mean_model <- train_data %>%
      group_by(company_name, dow, mon) %>%
      summarize(predicts = mean(target)) %>%
      ungroup()
    
    test_data <- left_join(test_data, mean_model,
                           by = c("company_name", "dow", "mon"))
    
    rmse[i] <- sqrt(mean((
      test_data$predicts - test_data$target
    ) ^ 2))
  }
  
  mean(rmse)
}

rmse_mean_model <- get_cv_rmse_mean_model(model_data, seed = 1)


#some feature engineering
model_data <- model_data %>%
  mutate(mon_dow = paste(month(pickup_date, label = TRUE),
                         as.character(wday(pickup_date, label = TRUE)),
                         sep = "_"))

mon_dow_lookup <- model_data %>%
  group_by(mon_dow) %>%
  summarise(mon_dow_encoded = mean(target))

#target encoding
model_data <-
  left_join(model_data, mon_dow_lookup, by = "mon_dow") %>%
  select(-mon_dow)

#start of long weekend (first day of two or more holidays in a row)
holidays <- holidays %>%
  mutate(start_long_we = ifelse(
    (lag(Japan) == 0 & Japan == 1 & lead(Japan) == 1) |
      wday(day) == 6 & Japan == 1 |
      wday(day) == 7 & lead(Japan, 2) == 1,
    1,
    0
  ))


model_data <- model_data %>%
  mutate(is_start_long_we = holidays$start_long_we[match(pickup_date, holidays$day)])

#upcoming events
avg_rent_duration <-
  as.numeric(mean(df_joined$return_date[df_joined$is_cancelled != 0] - df_joined$pickup_date[df_joined$is_cancelled != 0]))

get_events <- function(pickup_day) {
  evs <- events %>%
    filter(city_id != 1536 &
             start_date == pickup_day + 1 &
             end_date - start_date < avg_rent_duration)
  
  evs$dist <-
    apply(evs, 1, function(row)
      distm(as.numeric(row[6:7]), c(141.650876, 42.8209577), fun = distHaversine) /
        1000)
  
  nrow(subset(evs, dist > 60))
}

model_data$events <- sapply(model_data$pickup_date, get_events)



get_cv_rmse_rf_model <- function(data,
                                 k = 10,
                                 seed = 1) {
  set.seed(seed)
  
  data <- data %>%
    select(-pickup_date)
  
  data <- data[sample(nrow(data)), ]
  folds <- cut(seq(1, nrow(data)), breaks = k, labels = FALSE)
  rmse <- c()
  
  for (i in 1:k) {
    indices <- which(folds == i, arr.ind = TRUE)
    test_data <- data[indices, ]
    train_data <- data[-indices, ]
    
    rf_mod = randomForest(target ~ . , data = train_data)
    predicts <- predict(rf_mod, test_data[, -1])
    
    rmse[i] <- sqrt(mean((predicts - test_data$target) ^ 2))
  }
  mean(rmse)
}

rmse_rf_model <- get_cv_rmse_rf_model(model_data)

model_data$bad_weather <- ifelse(model_data$pickup_date %in% bad_weather$date, 1, 0)

#exploring weather conditions
df_cancelled <- df_joined %>% filter(
  is_cancelled == 1 &
    month(pickup_date) %in% c(12, 1, 2) &    #particular in winter
    (
      cancellation_date == pickup_date |
        cancellation_date - pickup_date < 2
    )
)

#according to https://en.wikipedia.org/wiki/Chitose,_Hokkaido
#in japanese Chitose is 千歳市, hereinafter correpondent city_id is 1536
city_weather <- weather %>% filter(city_id == 1536) %>%
  distinct(date, .keep_all = TRUE)

df_cancelled <- df_cancelled %>%
  inner_join(city_weather, by = c("pickup_date" = "date"))

weather_conditions <- df_cancelled %>%
  group_by(conditions) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

cloudy <- weather_conditions[1:7, 1]

bad_weather <- city_weather %>%
  filter(conditions %in% cloudy$conditions & low_temp < 0)



train2 <-
  dummy_cols(
    train,
    select_columns = c("company_name", "month", "day_of_week", "events_count"),
    remove_first_dummy = TRUE,
    remove_selected_columns = TRUE
  )

cv_ridge <- cv.glmnet(
  x = as.matrix(train[names(train) != "target"]),
  y = train[["target"]],
  nfolds = 10,
  standardize = TRUE,
  alpha = 0
)



cv_ridge$glmnet.fit$dev.ratio[which(cv_ridge$glmnet.fit$lambda == cv_ridge$lambda.min)]

rf_mod

sqrt(rf_mod$mse[length(rf_mod$mse)])

varImpPlot(rf_mod, type = 2)



# create hyperparameter grid
hyper_grid <- expand.grid(
  shrinkage = c(.3, .5, .7),
  interaction.depth = c(3, 5, 7),
  n.minobsinnode = c(5, 10, 15),
  bag.fraction = c(.5, .6, .8),
  optimal_trees = 0,
  # a place to dump results
  min_RMSE = 0                     # a place to dump results
)

# grid search
for (i in 1:nrow(hyper_grid)) {
  # reproducibility
  set.seed(1234)
  
  # train model
  gbm.tune <- gbm(
    formula = target ~ .,
    distribution = "gaussian",
    data = model_data[, -3],
    n.trees = 5000,
    interaction.depth = hyper_grid$interaction.depth[i],
    shrinkage = hyper_grid$shrinkage[i],
    n.minobsinnode = hyper_grid$n.minobsinnode[i],
    bag.fraction = hyper_grid$bag.fraction[i],
    train.fraction = .75,
    n.cores = NULL,
    # will use all cores by default
    verbose = FALSE
  )
  
  # add min training error and trees to grid
  hyper_grid$optimal_trees[i] <- which.min(gbm.tune$valid.error)
  hyper_grid$min_RMSE[i] <- sqrt(min(gbm.tune$valid.error))
}

gbm_tune <- gbm(
  formula = target ~ .,
  distribution = "gaussian",
  data = train_data,
  n.trees = 5,
  interaction.depth = 3,
  shrinkage = 0.7,
  n.minobsinnode = 5,
  bag.fraction = 0.6,
  train.fraction = .75,
  n.cores = NULL,
  # will use all cores by default
  verbose = FALSE
)

preds_gbm <- predict(gbm_tune, test_data[, -1])

rmse2
sqrt(mean((preds_gbm - test_data$target) ^ 2))
testData2$gbm <- preds_gbm
testData2$rf <- preds

hyper_grid %>%
  dplyr::arrange(min_RMSE) %>%
  head(10)
library(gbm)

data(mtcars)
Rf_model <- randomForest(mpg ~ ., data = mtcars)

rf_pred <- predict(Rf_model, mtcars) # predictions

Rf_model

sqrt(mean((rf_pred - mtcars$mpg) ^ 2)) #RMSE
sqrt(tail(f$mse, 1))

sqrt(mean((Rf_model$predicted - mtcars$mpg) ^ 2))
