library(tidyverse)
library(lubridate)    #parse dates
library(geosphere)    #calculate distance to event location
library(randomForest)
library(glmnet)
library(fastDummies)  #one-hot-encoding for ridge and xgb
library(gbm)
library(xgboost)


#all files were previously encoded to utf-8
description <- read_csv("data/encoded/columns_description.csv")
events <- read_csv("data/encoded/events_Hokkaido.csv")
holidays <- read_csv("data/encoded/holidays_Japan.csv")
jalan <- read_csv("data/encoded/jalan_shinchitose.csv")
rakuten <- read_csv("data/encoded/rakuten_shinchitose.csv")
weather <- read_csv("data/encoded/weather_Hokkaido.csv")

names(rakuten) <- description$`Row(EN)`[1:48]
names(jalan) <- description$`Row(EN)`[49:94]



#parsing dates in all input data
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



#identical columns within main datasets
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
    #num_of_passengers, #leave these cols for further predicting improvement
    #num_of_children,   #though not available for predicting might be useful
    #arrival_flight,    #for some feature engineering, such as assesing
    #total_price        #promotional offers etc
  )

df_joined <- bind_rows(jalan_filtered, rakuten_filtered)
#df_joined$arrival_flight[df_joined$arrival_flight == "0"] <- NA



write_csv(df_joined, "derived/df_joined.csv")



#preparing data in such a way to get a row with a
#target value for each company per each given date
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



ggplot(data = model_data, aes(x = pickup_date, y = target, color = company_name)) +
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

#target encoding for date
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
  
  nrow(subset(evs, dist > 60)) #manual adjustment
}

model_data$events <- sapply(model_data$pickup_date, get_events)



write_csv(model_data, "derived/model_data.csv")



#modelling
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
    predicts <- predict(rf_mod, test_data[,-1])
    
    rmse[i] <- sqrt(mean((predicts - test_data$target) ^ 2))
  }
  mean(rmse)
}

get_cv_rmse_ridge_model <- function(data,
                                    k = 10,
                                    seed = 1) {
  set.seed(seed)
  
  data <- data %>%
    select(-pickup_date) %>%
    dummy_cols(
      select_columns = c("company_name"),
      remove_first_dummy = TRUE,
      remove_selected_columns = TRUE
    )
  
  data <- data[sample(nrow(data)), ]
  folds <- cut(seq(1, nrow(data)), breaks = k, labels = FALSE)
  rmse <- c()
  
  for (i in 1:k) {
    indices <- which(folds == i, arr.ind = TRUE)
    test_data <- data[indices, ]
    train_data <- data[-indices, ]
    
    cv_ridge <- cv.glmnet(
      x = as.matrix(train_data[names(train_data) != "target"]),
      y = train_data[["target"]],
      nfolds = 10,
      standardize = TRUE,
      alpha = 0
    )
    
    predicts <-
      predict(cv_ridge,
              s = cv_ridge$lambda.min,
              newx = as.matrix(test_data[,-1]))
    
    rmse[i] <- sqrt(mean((predicts - test_data$target) ^ 2))
  }
  mean(rmse)
}

rmse_rf_model <- get_cv_rmse_rf_model(model_data)

rmse_ridge_model <- get_cv_rmse_ridge_model(model_data)



#trying to deal with weather forcast
city_weather <- weather %>% filter(city_id == 1536) %>%
  distinct(date, .keep_all = TRUE) %>%
  mutate(avg_temp = (low_temp + high_temp) / 2) %>%
  select(date, avg_temp) %>%
  complete(date = seq(date[1], as_date("2019-02-28"), by = "1 day")) %>%
  fill(avg_temp)

rented_cars <- df_joined %>%
  filter(is_cancelled == 0) %>%
  mutate(mon = month(pickup_date)) %>%
  group_by(mon) %>%
  summarise(rented = n()) %>%
  ungroup()

cancelled_orders <- df_joined %>%
  filter(is_cancelled == 1 &
           pickup_date - cancellation_date <= 1) %>%
  mutate(mon = month(pickup_date)) %>%
  group_by(mon) %>%
  summarise(cancelled = n()) %>%
  ungroup()

rush_cancellations <- rented_cars %>%
  left_join(cancelled_orders, by = "mon") %>%
  mutate(rush_ratio = cancelled / (rented + cancelled)) %>%
  select(mon, rush_ratio)

temp_drop_days <-
  tibble(drop = ifelse(diff(city_weather$avg_temp, 2) / na.omit(lag(
    city_weather$avg_temp, 2
  )) < 0, 1, 0),
  date = city_weather$date[3:nrow(city_weather)])

model_data_alt <- model_data %>%
  inner_join(temp_drop_days, by = c("pickup_date" = "date")) %>%
  mutate(drop = ifelse(drop == 1,
                       rush_cancellations$rush_ratio[match(month(pickup_date), rush_cancellations$mon)],
                       0))



write_csv(model_data_alt, "derived/model_data_alt.csv")



rmse_rf_model_alt_data <- get_cv_rmse_rf_model(model_data_alt)

rmse_ridge_model_alt_data <- get_cv_rmse_ridge_model(model_data_alt)



#gbm tuning via hyperparameter grid
hyper_grid <- expand.grid(
  shrinkage = c(.1, .3, .5),
  interaction.depth = c(3, 5, 7),
  n.minobsinnode = c(5, 10, 15),
  bag.fraction = c(.5, .6, .8),
  optimal_trees = 0,
  min_RMSE = 0
)

#grid search
for (i in 1:nrow(hyper_grid)) {
  set.seed(1)
  
  gbm_tune <- gbm(
    formula = target ~ .,
    distribution = "gaussian",
    data = model_data %>% select(-pickup_date),
    n.trees = 1000,
    interaction.depth = hyper_grid$interaction.depth[i],
    shrinkage = hyper_grid$shrinkage[i],
    n.minobsinnode = hyper_grid$n.minobsinnode[i],
    bag.fraction = hyper_grid$bag.fraction[i],
    train.fraction = .75,
    n.cores = NULL,
    verbose = FALSE
  )
  
  hyper_grid$optimal_trees[i] <- which.min(gbm_tune$valid.error)
  hyper_grid$min_RMSE[i] <- sqrt(min(gbm_tune$valid.error))
}

hyper_grid %>%
  arrange(min_RMSE) %>%
  head(10)


get_cv_rmse_gbm_model <- function(data,
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
    
    gbm_best <- gbm(
      formula = target ~ .,
      distribution = "gaussian",
      data = train_data,
      n.trees = 10,
      interaction.depth = 3,
      shrinkage = .5,
      n.minobsinnode = 15,
      bag.fraction = .5,
      train.fraction = .75,
      n.cores = NULL,
      verbose = FALSE
    )
    
    predicts <- predict(gbm_best, test_data[,-1])
    
    rmse[i] <- sqrt(mean((predicts - test_data$target) ^ 2))
  }
  mean(rmse)
}

rmse_gbm_model <- get_cv_rmse_gbm_model(model_data)

rmse_gbm_model_alt_data <- get_cv_rmse_gbm_model(model_data_alt)



#tuning xgboost via hyperparameter grid
hyper_grid_xgb <- expand.grid(
  eta = c(.01, .05, .1, .3),
  max_depth = c(1, 3, 5, 7),
  min_child_weight = c(1, 3, 5, 7),
  subsample = c(.6, .8, 1),
  colsample_bytree = c(.8, .9, 1),
  optimal_trees = 0,
  min_RMSE = 0
)


xgb_data <- model_data %>%
  select(-pickup_date) %>%
  dummy_cols(
    select_columns = c("company_name"),
    remove_first_dummy = TRUE,
    remove_selected_columns = TRUE
  )


#grid search
for (i in 1:nrow(hyper_grid_xgb)) {
  params <- list(
    eta = hyper_grid_xgb$eta[i],
    max_depth = hyper_grid_xgb$max_depth[i],
    min_child_weight = hyper_grid_xgb$min_child_weight[i],
    subsample = hyper_grid_xgb$subsample[i],
    colsample_bytree = hyper_grid_xgb$colsample_bytree[i]
  )
  
  set.seed(1)
  
  xgb_tune <- xgb.cv(
    params = params,
    data = as.matrix(xgb_data[names(xgb_data) != "target"]),
    label = xgb_data[["target"]],
    nrounds = 1000,
    nfold = 5,
    objective = "reg:squarederror",
    verbose = 0,
    early_stopping_rounds = 10  #stop if no improvement for 10 consecutive trees
  )
  
  hyper_grid_xgb$optimal_trees[i] <-
    which.min(xgb_tune$evaluation_log$test_rmse_mean)
  hyper_grid_xgb$min_RMSE[i] <-
    min(xgb_tune$evaluation_log$test_rmse_mean)
}

hyper_grid_xgb %>%
  arrange(min_RMSE) %>%
  head(10)


get_cv_rmse_xgb_model <- function(data,
                                  k = 10,
                                  seed = 1) {
  set.seed(seed)
  
  data <- data %>%
    select(-pickup_date) %>%
    dummy_cols(
      select_columns = c("company_name"),
      remove_first_dummy = TRUE,
      remove_selected_columns = TRUE
    )
  
  data <- data[sample(nrow(data)), ]
  folds <- cut(seq(1, nrow(data)), breaks = k, labels = FALSE)
  
  params_final <- list(
    eta = 0.01,
    max_depth = 3,
    min_child_weight = 1,
    subsample = 0.6,
    colsample_bytree = 1
  )
  
  rmse <- c()
  
  for (i in 1:k) {
    indices <- which(folds == i, arr.ind = TRUE)
    test_data <- data[indices, ]
    train_data <- data[-indices, ]
    
    xgb_mod <- xgboost(
      params = params_final,
      data = as.matrix(train_data[names(train_data) != "target"]),
      label = train_data[["target"]],
      nrounds = 365,
      objective = "reg:squarederror",
      verbose = 0
    )
    
    predicts <-
      predict(xgb_mod,
              as.matrix(test_data[,-1]))
    
    rmse[i] <- sqrt(mean((predicts - test_data$target) ^ 2))
  }
  mean(rmse)
}


rmse_xgb_model <- get_cv_rmse_xgb_model(model_data)

rmse_xgb_model_alt_data <- get_cv_rmse_xgb_model(model_data_alt)


#parameter list
params_final <- list(
  eta = 0.01,
  max_depth = 3,
  min_child_weight = 1,
  subsample = 0.6,
  colsample_bytree = 1
)

#train final model for xgb
xgb_fit_final <- xgboost(
  params = params_final,
  data = as.matrix(xgb_data[names(xgb_data) != "target"]),
  label = xgb_data[["target"]],
  nrounds = 365,
  objective = "reg:squarederror",
  verbose = 0
)


#train final model for ridge on model_data_alt
ridge_data_alt <- model_data_alt %>%
  select(-pickup_date) %>%
  dummy_cols(
    select_columns = c("company_name"),
    remove_first_dummy = TRUE,
    remove_selected_columns = TRUE
  )

ridge_fit_final_alt <- cv.glmnet(
  x = as.matrix(ridge_data_alt[names(ridge_data_alt) != "target"]),
  y = ridge_data_alt[["target"]],
  nfolds = 10,
  standardize = TRUE,
  alpha = 0
)

saveRDS(params_final, "results/models/xgb_param.rds")
saveRDS(xgb_fit_final, "results/models/xgb_model.rds")
saveRDS(ridge_fit_final_alt, "results/models/ridge_model_alt.rds")



#features importance
importance_matrix <- xgb.importance(model = xgb_fit_final)
xgb.plot.importance(importance_matrix, measure = "Gain")

rf_mod_alt <-
  randomForest(target ~ . , data = model_data_alt %>% select(-pickup_date))
varImpPlot(rf_mod_alt)


#new data for Jan-Feb 2019
new_data <- tibble(date = rep(seq(
  as_date("2019-01-01"), as_date("2019-02-28"), by = "1 day"
), each = 2),
company_name = rep(c("rakuten", "jalan"), length(date) / 2)) %>%
  mutate(
    mon_dow = paste(month(date, label = TRUE),
                    as.character(wday(date, label = TRUE)),
                    sep = "_"),
    mon_dow_encoded = mon_dow_lookup$mon_dow_encoded[match(mon_dow, mon_dow_lookup$mon_dow)],
    is_start_long_we = holidays$start_long_we[match(date, holidays$day)],
    events = sapply(date, get_events),
    is_drop_temp = temp_drop_days$drop[match(date, temp_drop_days$date)],
    drop = ifelse(is_drop_temp == 1,
                  rush_cancellations$rush_ratio[match(month(date), rush_cancellations$mon)],
                  0)
  ) %>%
  dummy_cols(
    select_columns = c("company_name"),
    remove_first_dummy = TRUE,
    remove_selected_columns = TRUE
  ) %>%
  select(-mon_dow,-is_drop_temp)



#make final predictions
xgb_new_data_preds <-
  predict(xgb_fit_final,
          as.matrix(new_data[,-c(1, 5)]))

ridge_new_data_preds_alt <-
  c(predict(
    ridge_fit_final_alt,
    s = ridge_fit_final_alt$lambda.min,
    newx = as.matrix(new_data[,-1])
  ))


#saving results
results <-
  cbind(new_data[, c(1, 6)], xgb_new_data_preds, ridge_new_data_preds_alt)  %>%
  mutate(
    xgb_rounded = round(xgb_new_data_preds, 0),
    ridge_rounded = round(ridge_new_data_preds_alt, 0)
  )

results_jalan <- subset(results, company_name_jalan == 1)
results_rakuten <- subset(results, company_name_jalan == 0)


write_csv(results_rakuten[, c(1, 3)], "results/predictions/rakuten_xgb_raw.csv")
write_csv(results_rakuten[, c(1, 5)],
          "results/predictions/rakuten_xgb_rounded.csv")
write_csv(results_rakuten[, c(1, 4)], "results/predictions/rakuten_alt_raw.csv")
write_csv(results_rakuten[, c(1, 6)],
          "results/predictions/rakuten_alt_rounded.csv")

write_csv(results_jalan[, c(1, 3)], "results/predictions/jalan_xgb_raw.csv")
write_csv(results_jalan[, c(1, 5)], "results/predictions/jalan_xgb_rounded.csv")
write_csv(results_jalan[, c(1, 4)], "results/predictions/jalan_alt_raw.csv")
write_csv(results_jalan[, c(1, 6)], "results/predictions/jalan_alt_rounded.csv")