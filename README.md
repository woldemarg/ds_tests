City of Chitose - https://en.wikipedia.org/wiki/Chitose,_Hokkaido

What is Shin-Chitose? - https://www.japan-guide.com/forum/quereadisplay.html?0+57892

New Chitose Airport - https://en.wikipedia.org/wiki/New_Chitose_Airport

My assumptions:
1. Citizens rent a car to get to/out of the airport
2. Citizens rent a car to get to events in another city
3. Rental frequency might depend on day of week and holiday
4. Rental frequency might depend on company name and car park available

Data available for predictioning:
1. Date (i.e. day of week and month)
2. Schedule of events in neighbourhood areas (i.e. number of events per giveb day, average distance from Chitose, average duration)
3. Weather forecast
4. Company name
5. Car class

Hypothesis:
1. Do number of cancellations correspond with a bad weather conditions (suggesting intention to avoid risky driving)?
2. Will introducing such a new feature as car_company with further target encoding by average price per day improve our model?

Model evaluation:

Compare with naive approach of calculating average number of orders for car_company grouped by day of week and month



Further improvements:
1. Get schedule of flights available for forecasting
2. Somehow estimate activity of competitors for a given company