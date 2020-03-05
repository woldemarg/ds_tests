library(tidyverse)
library(lubridate)
library(geosphere)
library(randomForest)
library(glmnet)
library(fastDummies)
library(splus2R)




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


#identical columns within datasets
jalan_filtered <- jalan %>%
  mutate(
    company_name = "jalan",
    request_date = get_date(request_date_time),
    pickup_date = get_date(pickup_date_time),
    return_date = get_date(return_date_time),
    cancellation_date = get_date(cancellation_date_time),
    is_cancelled = ifelse(!is.na(cancellation_date_time), 1, 0),
    num_of_passengers = as.numeric(str_extract_all(number_of_passengers, "\\d+")[[1]][1]),
    num_of_children = as.numeric(str_extract_all(number_of_passengers, "\\d+")[[1]][2])
  ) %>%
  select(
    company_name,
    request_date,
    pickup_date,
    return_date,
    request_date,
    cancellation_date,
    is_cancelled,
    num_of_passengers,
    num_of_children,
    arrival_flight,
    total_price
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
  rename(
    car_class = company_car_class_code,
    num_of_passengers = number_of_passengers,
    num_of_children = number_of_children,
    arrival_flight = flight_number,
    total_price = taxable_amount
  ) %>%
  select(
    company_name,
    request_date,
    pickup_date,
    return_date,
    request_date,
    cancellation_date,
    is_cancelled,
    num_of_passengers,
    num_of_children,
    arrival_flight,
    total_price
  )

df_joined <- bind_rows(jalan_filtered, rakuten_filtered)
df_joined$arrival_flight[df_joined$arrival_flight == "0"] <- NA

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


#summing up events outside the city
sum_up_events <- function(date,
                          city_id_excl = 1536,
                          city_centre = c(141.650876, 42.8209577),
                          data = events) {
  events_in_neighbourhood <-
    data %>% filter(city_id != city_id_excl & start_date == date)
  
  if (nrow(events_in_neighbourhood) == 0) {
    ls <- list(
      start_date = date,
      cnt = 0,
      dis = 0,
      dur = 0
    )
    return(ls)
  }
  
  events_in_neighbourhood$duration <- ifelse(
    events_in_neighbourhood$end_date - events_in_neighbourhood$start_date == 0,
    1,
    events_in_neighbourhood$end_date - events_in_neighbourhood$start_date
  )
  
  events_in_neighbourhood$distance <-
    distm(events_in_neighbourhood[, 6:7], city_centre, fun = distHaversine)
  
  events_groupped <- events_in_neighbourhood %>%
    group_by(start_date) %>%
    summarise(cnt = n(),
              dis = mean(distance),
              dur = mean(duration)) %>%
    ungroup()
  
  ls <- as.list(events_groupped[1,])
}

events_sum_up_ls <-
  lapply(unique(df_joined$pickup_date), sum_up_events)

events_sum_up_df <-
  as_tibble(t(matrix(
    unlist(events_sum_up_ls), nrow = length(unlist(events_sum_up_ls[1]))
  )), .name_repair = "unique")

names(events_sum_up_df) <- c("date",
                             "events_count",
                             "events_avg_distance",
                             "events_avg_duration")

events_sum_up_df$date <- as_date(events_sum_up_df$date)


#target encoding company by average price per day
#
# lookup <- df_joined %>% filter(is_cancelled == 0) %>%
#   mutate(duration = ifelse(return_date - pickup_date == 0,
#                            1,
#                            return_date - pickup_date)) %>%
#   group_by(company_name) %>%
#   summarise(encoded_company = mean(total_price) / mean(duration)) %>%
#   ungroup()


#preparing data
model_data <- df_joined %>%
  filter(is_cancelled == 0) %>%
  group_by(pickup_date, company_name) %>%
  summarise(target = n())

model_data_wide <- model_data %>%
  pivot_wider(names_from = pickup_date, values_from = target)

model_data_wide[is.na(model_data_wide)] <- 0

model_data <- model_data_wide %>%
  pivot_longer(names(model_data_wide)[-1],
               names_to = "pickup_date",
               values_to = "target")

model_data$pickup_date <- as_date(model_data$pickup_date)

model_data <- model_data %>%
  mutate(
    day_of_week = as_factor(as.character(wday(pickup_date, label = TRUE))),
    month = as_factor(month(pickup_date)),
    is_holiday = holidays$Japan[match(pickup_date, holidays$day)],
    is_bad_weather = ifelse(pickup_date %in% bad_weather$date, 1, 0)
  ) %>%
  left_join(events_sum_up_df, by = c("pickup_date" = "date")) %>%
  #left_join(lookup, by = "company_name") %>%
  select(-pickup_date)

model_data$company_name <- as_factor(model_data$company_name)

rf_mod <- tuneRF(
  x = model_data[names(model_data) != "target"],
  y = model_data[["target"]],
  ntreeTry = 1500,
  stepFactor = 1.5,
  improve = 1e-5,
  #classwt = wt,
  trace = FALSE,
  plot = FALSE,
  doBest = TRUE
)

str(model_data)

train <-
  dummy_cols(
    model_data,
    select_columns = c("company_name", "day_of_week", "month"),
    remove_first_dummy = TRUE,
    remove_selected_columns = TRUE
  )

str(train)

cv_ridge <- cv.glmnet(
  x = as.matrix(train[names(train) != "target"]),
  y = train[["target"]],
  nfolds = 10,
  standardize = TRUE,
  alpha = 0
)

cv_ridge

cv_ridge$glmnet.fit$dev.ratio[which(cv_ridge$glmnet.fit$lambda == cv_ridge$lambda.min)]

rf_mod

varImpPlot(rf_mod, type = 2)

change_pseudo_num_cols_to_factors <- function(data, lim = 15) {
  sum <- get_summary(data)
  pseudo_num <- sum %>%
    filter(cls == "numeric" &
             unq < lim &
             !(fnm %in% c(ords$f, "OverallQual", "OverallCond"))) %>%
    select(fnm) %>%
    pull(fnm)
  v <- model_data$events_avg_distance
  n_vars <-
    as_tibble(lapply(data[pseudo_num], function(v) {
      t <- table(v)
      p <- peaks(t)
      p
      n <- names(t)
      n[p]
      b <- as.numeric(c("0", n[p], Inf))
      b
      
      b <- if (length(n[p]) == 0) {
        c("-1", "0", n[length(n)])
      } else {
        if ("0" %in% n[p]) {
          c("-1", n[p], n[length(n)])
        } else {
          if ("0" %in% n) {
            c("-1", "0", n[p], n[length(n)])
          } else {
            c(n[1], n[p], n[length(n)])
          }
        }
      }
      return(cut(v, breaks = as.numeric(b), include.lowest = TRUE))
    }))
  
  
  #Randomly shuffle the data
  d <- model_data[sample(nrow(model_data)), 1:4]
  
  #Create 10 equally size folds
  folds <- cut(seq(1, nrow(d)), breaks = 10, labels = FALSE)
  #Perform 10 fold cross validation
  rsq <- function (x, y)
    cor(x, y) ^ 2
  
  rmse <- c()
  r2 <- c()
  
  for (i in 1:10) {
    #Segement your data by fold using the which() function
    testIndexes <- which(folds == i, arr.ind = TRUE)
    testData <- d[testIndexes,]
    trainData <- d[-testIndexes,]
    #Use the test and train data partitions however you desire...
    mean_model <- trainData %>%
      group_by(company_name, month, day_of_week) %>%
      summarize(predicts = mean(target))
    
    testData <- testData %>%
      left_join(mean_model, by = c("company_name", "month", "day_of_week"))
    
    rmse[i] <- sqrt(sum(testData$predicts - testData$target) ^ 2)
    
    r2[i] <- rsq(testData$predicts, testData$target)
  }
  mean(rmse)
  mean(r2)
  