#install.packages("tidyverse")
#install.packages("lubridate")
#install.packages("geosphere")

library(tidyverse)
library(lubridate)
library(geosphere)

description <- read_csv("data/encoded/columns_description.csv")
events <- read_csv("data/encoded/events_Hokkaido.csv")
holidays <- read_csv("data/encoded/holidays_Japan.csv")
jalan <- read_csv("data/encoded/jalan_shinchitose.csv")
rakuten <- read_csv("data/encoded/rakuten_shinchitose.csv")
weather <- read_csv("data/encoded/weather_Hokkaido.csv")

names(rakuten) <- description$`Row(EN)`[1:48]
names(jalan) <- description$`Row(EN)`[49:94]


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
    car_class,
    transmission,
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
    car_class,
    transmission,
    num_of_passengers,
    num_of_children,
    arrival_flight,
    total_price
  )

df_joined <- bind_rows(jalan_filtered, rakuten_filtered)
df_joined$arrival_flight[df_joined$arrival_flight == "0"] <- NA

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

events_sum_up_ls <- lapply(df_joined$pickup_date, sum_up_events)

events_sum_up_df <-
  as_tibble(t(matrix(
    unlist(events_sum_up_ls), nrow = length(unlist(f[1]))
  )), .name_repair = "unique")

names(events_sum_up_df) <- c("date",
                             "events_count",
                             "events_avg_distance",
                             "events_avg_duration")

events_sum_up_df$date <- as_date(events_sum_up_df$date)

#according to https://en.wikipedia.org/wiki/Chitose,_Hokkaido
#in japanese Chitose is 千歳市, correpondent city_id is 1536
df_extended <- df_joined %>%
  mutate(day_of_week = wday(pickup_date, label = TRUE),
         is_holiday = holidays$Japan[match(pickup_date, holidays$day)]) %>%
  left_join(events_sum_up_df, by = c("pickup_date" = "date"))

df_extended$month <- month(df_extended$pickup_date) 
