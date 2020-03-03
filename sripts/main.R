#install.packages("tidyverse")

library(tidyverse)

description <- read_csv("data/encoded/columns_description.csv")
events <- read_csv("data/encoded/events_Hokkaido.csv")
holidays <- read_csv("data/encoded/holidays_Japan.csv")
jalan <- read_csv("data/encoded/jalan_shinchitose.csv")
rakuten <- read_csv("data/encoded/rakuten_shinchitose.csv")
weather <- read_csv("data/encoded/weather_Hokkaido.csv")

names(rakuten) <- description$`Row(EN)`[1:48]
names(jalan) <- description$`Row(EN)`[49:94]

