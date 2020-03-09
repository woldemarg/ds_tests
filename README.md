# Introductory note
*Chitose* is known as a city in Hokkaido according to https://en.wikipedia.org/wiki/Chitose,_Hokkaido. The name of a  city was denoted by names of the given files, more specifically *jalan_shinchitose.csv* and *rakuten_shinchitose.csv*. Those names contain an extending *-shin-* which means *new* in Japanese https://www.japan-guide.com/forum/quereadisplay.html?0+57892 and therefore bring us new knowledge about *New Chitose Airport* as described here https://en.wikipedia.org/wiki/New_Chitose_Airport.

# Initial setup
All given files were initially encoded to utf_8 in Notepad++ and stored as input data at [encoded](https://github.com/woldemarg/lightit_test/tree/master/data/encoded) folder.

# Model assumptions
My initial assumptions regarding the task were as follows: 
1. Citizens rent a car to get to/out of the airport
2. Citizens rent a car to get to events in another city (i.e. locations outside *Chintose*)
3. Rental frequency might depend on the day of week and month
4. Rental frequency might depend on the company name (i.e. position on the market and prices

# Data available for predicting:
1. Date (i.e. day of week and month)
2. Schedule of events in neighbourhood areas (i.e. the number of events per given day, the average distance from *Chitose*, average duration)
3. Weather forecast (do the number of cancellations correspond with bad weather conditions, such as temperature dropdown, suggesting an intention to avoid risky driving in winter or busman's holiday in summer?)
4. Company name

# Applied algorithms
1. Ridge regression
2. Random forest
3. Gradient boosted machines
4. Extreme gradient boosting 

# Comparative metrics
RMSE on 10-fold cross-validation is used to compare models to each other as well as to  "simple mean" approach (predicting future orders based on month and day-of-week average per each company)

# New features introduced
1. *mon_dow_encoded* - grouped month-and-day-of-week variable encoded by target (mean of car rentals per correspondent day-of-week and month pair)
2. *is_start_long_we* - is given date a start of a "long" weekend (two or more holidays in a row, not including Saturday and Sunday, or Saturday and Sunday plus Monday as a holiday etc.). It is supposed that citizens will tend to rent more cars before "long" holidays as they have more time to stand outside the city
3. *events* - number of events beyond the borders of *Chintose* with an average duration equal or less than the average duration of a car rental, but within the distance of 60 km from the centre of *Chintose*. This was estimated somehow heuristically but prooved to slightly increase model efficiency
4. *drop* - in a fashion a hysteresis experimental feature to asses the impact of change in weather conditions on a rental statistic. The logic of introducing this feature is as follows: since the rental act is a matter of aforehand planning numerous facts of cancelling orders in a day (or even at the same day) as the pickup day may be caused by unexpected changes in external circumstances such as but not limited to weather conditions. *drop* denotes average (per comparable month) ratio of "rush cancellations" to the total number of orders for a given day if it keeps track of temperature dropdown for the previous day. Introducing this feature showed no improvement on the model and resulted in the reduction of train dataset, thus was used in an alternative dataset for modelling, stored at [derived](https://github.com/woldemarg/lightit_test/tree/master/derived) folder

# Results
by RMSE on 10-fold CV on model_data / model_data_alt (incl. weather feature) set:
1. **2.03** / 2.08 - xgb
2. 2.04 / **2.07** - ridge regression
3. 2.06 / 2.12 - gbm
4. 2.09 / 2.15 - rf
5. 2.15 / ---- - mean by mon_dow
(somewhat different for *holomb_test.ipynb*)

Predictions are available at [results/predictions](https://github.com/woldemarg/lightit_test/tree/master/results/predictions) folder, while scripts (incl .ipynb) are in [scripts](https://github.com/woldemarg/lightit_test/tree/master/sripts) folder.

# What to be improved
1. Get a schedule of flights available for forecasting
2. Somehow estimate inter influence (trade-off)  of activities (rental statistics) of competitors on the market
3. Take into consideration promotional offers (coupons etc)

--
Volodymyr Holomb,
analytics and data processing
Zaporizhzhya, Ukraine
http://woldemarg.github.io/portfolio/