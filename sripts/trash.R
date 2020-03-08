select(-ratio) %>%
  left_join(ref_can, by = c("mon"))

dif <-
  diff(city_weather$avg_temp, 2) / na.omit(lag(city_weather$avg_temp, 2))
name <- sprintf("%s_%s", "dif", 2)
d <- enframe(dif)[, 2]
names(d) <- name
#d <- bind_cols(d, city_weather2[3:nrow(city_weather2),c(1,3)])

d <- bind_cols(d, city_weather[3:nrow(city_weather), 1]) %>%
  mutate(dif_2 = ifelse(dif_2 < 0, 1, 0)) %>%
  inner_join(ref_can, by = c("date" = "pickup_date"))

d$mon <- month(d$date)
create_lagged_table <- function(data, lags = 2) {
  ls <- list()
  for (i in 0:lags) {
    lag <- lapply(data[, 2], function(col)
      lag(col, i))
    names(lag) <- sprintf("%s_%s", names(lag), i)
    
    ls[[i + 1]] <- lag
  }
  out <- bind_cols(data[, 1], ls) %>%
    na.omit()
  
}

g <- create_lagged_table(city_weather)


create_lagged_diff <- function(data, lags = 3) {
  data$avg_temp[data$avg_temp == 0] <- 0.5
  
  dif <- diff(data$avg_temp, 1) / data$avg_temp[2:nrow(data)]
  ls <- list()
  for (i in 1:lags) {
    name <- sprintf("%s_%s", "dif", i)
    ls[[name]] <- lag(dif, i - 1)
  }
  out <- as_tibble(ls) %>%
    na.omit() %>%
    bind_cols(data[(lags + 1):nrow(data), 1], .)
  
}

h <- create_lagged_diff(city_weather2)




d_lookup <- d %>%
  group_by(dif_2, mon) %>%
  summarise(avg = mean(ratio)) %>%
  ungroup() %>%
  filter(dif_2 == 1)

d$m_y <- paste(year(d$date), month(d$date), sep = "_")
d2 <- d %>% group_by(m_y) %>%
  mutate(my_avg = mean(avg_temp)) %>%
  ungroup() %>%
  mutate(drop = dif_2 / my_avg)




mod <- inner_join(g, ref_can, by = c("date" = "pickup_date")) #%>%
mutate(month = as_factor(month(date))) %>%
  select(-date)

mod2 <- inner_join(h, ref_can, by = c("date" = "pickup_date")) %>%
  mutate(month = as_factor(month(date))) %>%
  select(-date) %>% select(ratio, everything())

mod3 <- inner_join(d2, ref_can, by = c("date" = "pickup_date")) %>%
  mutate(month = as_factor(month(date))) %>%
  select(6:8) %>% select(ratio, everything())

mod2$dif_1 <- ifelse(mod2[["dif_1"]] < 0, 1, 0)
mod2$dif_2 <- ifelse(mod2[["dif_2"]] < 0, 1, 0)
mod2$dif_3 <- ifelse(mod2[["dif_3"]] < 0, 1, 0)
mod2$dif_2 <- cut(mod2[["dif_2"]], breaks = 3)

sum(is.na(mod2))
str(mod2)

get_cv_r2_rf_model <- function(data,
                               k = 10,
                               seed = 1) {
  set.seed(seed)
  
  data <- data[sample(nrow(data)), ]
  folds <- cut(seq(1, nrow(data)), breaks = k, labels = FALSE)
  r2 <- c()
  
  for (i in 1:k) {
    indices <- which(folds == i, arr.ind = TRUE)
    test_data <- data[indices, ]
    train_data <- data[-indices, ]
    
    rf_mod = randomForest(ratio ~ . , data = train_data)
    predicts <- predict(rf_mod, test_data[,-1])
    
    r2[i] <-
      1 - sum((test_data$ratio - predicts) ^ 2) / sum((test_data$ratio - mean(test_data$ratio)) ^
                                                        2)
  }
  mean(r2)
}

r2_rf_model <- get_cv_r2_rf_model(mod3)


set.seed(1)
rf = randomForest(ratio ~ . , data = mod3)
rf
varImpPlot(rf)
plot(rf)

mod3 <-
  dummy_cols(
    mod3,
    select_columns = c("month"),
    remove_first_dummy = TRUE,
    remove_selected_columns = TRUE
  )


predicts2 <- predict(rf, test_data[,-1])

cv_ridge <- cv.glmnet(
  x = as.matrix(mod3[names(mod3) != "ratio"]),
  y = mod3[["ratio"]],
  nfolds = 10,
  standardize = FALSE,
  alpha = 0
)


test <- model_data %>%
  left_join(ref_can, by = "pickup_date") %>%
  filter(pickup_date %in% city_weather$date)



test2$ratio[test2$dif_2 == 0] <-  0



filter(pickup_date %in% city_weather$date)

l <- cut(d$ratio, breaks = 2)
levels(l)

for (i in 2:length(unique(test$ratio))) {
  ds <- test2[-7:-8]
  ds$ratio <- cut(ds$ratio, breaks = i)
  
  r <- get_cv_rmse_rf_model(ds)
  cat(i, r, "\n")
  
}
data = model_data



t <- df_joined %>%
  filter(is_cancelled == 1) %>%
  mutate(avg = pickup_date - cancellation_date)

length(unique(d$ratio))
l <- cut(d$ratio, breaks = 14)
levels(l)
mutate(ratio = mod$ratio[match(pickup_date, mod$date)]) %>%
  na.omit()

cv_ridge

cv_ridge$glmnet.fit$dev.ratio[which(cv_ridge$glmnet.fit$lambda == cv_ridge$lambda.min)]

t <- predict(cv_ridge, mod3[, -1])

set.seed(157)
mf.negative <- MetaForest(ratio ~ ., num.trees = 1000, data = mod2)
#Check convergence
plot(mf.negative)


install.packages("metaforest")
library(metaforest)
set.seed(11)
#Replicate the metaforest analysis 100 times, and store only the r squared and variable importance metrics
mf.replications <- replicate(100, {
  mf_tmp <- MetaForest(ratio ~ ., num.trees = 1000, data = mod)
  list(
    r.squared = mf_tmp$forest$r.squared,
    varimp = mf_tmp$forest$variable.importance
  )
}, simplify = FALSE)
# Make a data.frame with r squared values
rsquared <-
  data.frame(r.squared = sapply(mf.replications, function(x) {
    x[["r.squared"]]
  }))
#Plot the kernel density of the r squared values
ggplot(rsquared, aes(r.squared)) +
  geom_density() +
  theme_bw()

length(unique(model_data$pickup_date))
df <- tibble(
  date_0 = city_weather2$date,
  cond_0 = city_weather2$conditions,
  temp_0 = city_weather2$avg_temp,
  rain_1 = city_weather2$rain_probability,
  date_0 = city_weather2$date,
  cond_0 = city_weather2$conditions,
  temp_0 = city_weather2$avg_temp,
  rain_0 = city_weather2$rain_probability,
  date_0 = city_weather2$date,
  cond_0 = city_weather2$conditions,
  temp_0 = city_weather2$avg_temp,
  rain_0 = city_weather2$rain_probability,
  
)
model_data$bad_weather <-
  ifelse(model_data$pickup_date %in% bad_weather$date, 1, 0)

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





rmse2
sqrt(mean((preds_gbm - test_data$target) ^ 2))
testData2$gbm <- preds_gbm
testData2$rf <- preds


library(gbm)

data(mtcars)
Rf_model <- randomForest(mpg ~ ., data = mtcars)

rf_pred <- predict(Rf_model, mtcars) # predictions

Rf_model

sqrt(mean((rf_pred - mtcars$mpg) ^ 2)) #RMSE
sqrt(tail(f$mse, 1))

sqrt(mean((Rf_model$predicted - mtcars$mpg) ^ 2))

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
    
    gbm_mod <- gbm(
      formula = target ~ .,
      distribution = "gaussian",
      data = train_data,
      n.trees = 35,
      interaction.depth = 3,
      shrinkage = 0.1,
      n.minobsinnode = 10,
      bag.fraction = 0.5,
      train.fraction = .95,
      n.cores = NULL,
      # will use all cores by default
      verbose = FALSE
    )
    
    predicts <- predict(gbm_mod, test_data[,-1])
    
    rmse[i] <- sqrt(mean((predicts - test_data$target) ^ 2))
  }
  mean(rmse)
}

rmse_gbm_model <- get_cv_rmse_gbm_model(test)
