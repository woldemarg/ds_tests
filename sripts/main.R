#install.packages("tidyverse")
#install.packages("lubridate")


library(tidyverse)
library(lubridate)


description <- read_csv("data/encoded/columns_description.csv")
events <- read_csv("data/encoded/events_Hokkaido.csv")
holidays <- read_csv("data/encoded/holidays_Japan.csv")
jalan <- read_csv("data/encoded/jalan_shinchitose.csv")
rakuten <- read_csv("data/encoded/rakuten_shinchitose.csv")
weather <- read_csv("data/encoded/weather_Hokkaido.csv")

names(rakuten) <- description$`Row(EN)`[1:48]
names(jalan) <- description$`Row(EN)`[49:94]

#https://en.wikipedia.org/wiki/Chitose,_Hokkaido
#Chitose 千歳市 1536

get_date <- function(timestamp) {
  return(date(parse_date_time(timestamp, "Y/m/d H:M")))
}

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
