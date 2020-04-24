import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

from scipy import stats
from functools import reduce

#%%
description = pd.read_csv("../data/encoded/columns_description.csv",
                          index_col=0)
description.reset_index(drop=True, inplace=True)

events = pd.read_csv("../data/encoded/events_Hokkaido.csv")
holidays = pd.read_csv("../data/encoded/holidays_Japan.csv")
weather = pd.read_csv("../data/encoded/weather_Hokkaido.csv")

#%%
jalan_dcols_to_parse = [5, 6, 7, 10]
jalan = pd.read_csv("../data/encoded/jalan_shinchitose.csv",
                    parse_dates=jalan_dcols_to_parse)

rakuten_dcols_to_parse = [4, 6, 16, 19]
rakuten = pd.read_csv("../data/encoded/rakuten_shinchitose.csv",
                      parse_dates=rakuten_dcols_to_parse)

#%%
jalan.columns = description.loc[48:93, "Row(EN)"]
rakuten.columns = description.loc[:47, "Row(EN)"]

cols_to_select = ["company_name",
                  "request_date_time",
                  "pickup_date_time",
                  "return_date_time",
                  "cancellation_date_time",
                  "is_cancelled"]

jalan = (jalan
         .assign(company_name="jalan")
         .assign(is_cancelled=np.invert(np.isnat(jalan.cancellation_date_time))
                 .astype(int))
         .loc[:, cols_to_select])

rakuten = (rakuten
           .assign(company_name="rakuten")
           .assign(is_cancelled=np.invert(
               np.isnat(rakuten.cancel_request_date_time)).astype(int))
           .rename(columns={
               "cancel_request_date_time": "cancellation_date_time"})
           .loc[:, cols_to_select])

#%%
def extract_date(row):
    """Get date from all date_time columns in a given row."""
    row.iloc[1:-1] = row.iloc[1:-1].dt.date
    return row


raw_data = (pd.concat([jalan, rakuten], axis=0)
            .reset_index(drop=True)
            .apply(extract_date, axis=1)
            .rename(columns=(lambda x: x[:-5]
                    if x.endswith('_time') else x)))
#%%
model_data = (raw_data.loc[raw_data.is_cancelled != 1, :]
              .groupby(["company_name", "pickup_date"])
              .agg(target=pd.NamedAgg(column="pickup_date",
                                      aggfunc="count"))
              #.pickup_date.agg('count').to_frame("target") #same as above
              .reset_index())

days_wo_rakuten = (model_data.groupby("pickup_date")
                   .filter(lambda g: all(g.company_name == "jalan"))
                   .assign(company_name="rakuten")
                   .assign(target=0))

days_wo_jalan = (model_data.groupby("pickup_date")
                 .filter(lambda g: all(g.company_name == "rakuten"))
                 .assign(company_name="jalan")
                 .assign(target=0))

model_data = (pd.concat([model_data, days_wo_rakuten, days_wo_jalan], axis=0)
              .reset_index(drop=True)
              .sort_values(by=["pickup_date", "company_name"]))

model_data.to_csv("../derived/model_data_py.csv", index=False)

#%%
timeline_raw = pd.pivot_table(model_data,
                              values="target",
                              index=["pickup_date"],
                              columns=["company_name"])

dates_index = pd.date_range(min(timeline_raw.index),
                            max(timeline_raw.index),
                            freq="D")

timeline_days = timeline_raw.reindex(dates_index, fill_value=0)

timeline_weeks = (timeline_days
                  .groupby(pd.PeriodIndex(timeline_days.index, freq="W"))
                  .sum())

#%%
def apply_polynomial(y, d):
    poly = np.poly1d(np.polyfit(range(1, 53), y.groupby(y.index.week).mean(), d))
    rmse = np.sqrt(((poly(y.index.week) - y) ** 2).mean())
    return poly, rmse


def remove_seasonality(series):
    weeks = series.index.week
    degree = 2
    model, rmse = apply_polynomial(series, degree)

    while True:
        degree += 1
        new_model, new_rmse = apply_polynomial(series, degree)
        if rmse - new_rmse < 0.5:
            best_model, best_rmse = new_model, new_rmse
            break
        rmse = new_rmse

    s_component = best_model(series.index.week)
    a_series = np.subtract(series.reset_index(drop=True), s_component)

    return s_component, a_series


for i, s in enumerate(["jalan", "rakuten"], 1):
    s_component, a_series = remove_seasonality(timeline_weeks[s])
    plt.subplot(1, 2, i)
    plt.plot(timeline_weeks[s].reset_index(drop=True))
    plt.plot(s_component, color="red")
    plt.title(s)
    plt.ylim(0, 70)

#%%
rakuten_seasonality, rakuten_adjusted = remove_seasonality(timeline_weeks.rakuten)
jalan_seasonality, jalan_adjusted = remove_seasonality(timeline_weeks.jalan)

plt.boxplot([jalan_adjusted, rakuten_adjusted])
plt.xticks([1, 2],["jalan", "rakuten"])

#%%
def get_outliers(*series):
    out = []
    for s in series:
        zscores = list(np.abs(stats.zscore(s)))
        indicies = [i for i, v in enumerate(zscores) if v >= 2.5]
        out.append(indicies)

    return list(dict.fromkeys(reduce(lambda x, y: x + y, out)))


out_periods = (timeline_weeks
               .reset_index()
               .iloc[get_outliers(jalan_adjusted,
                                  rakuten_adjusted)]["index"]
               .rename("period"))

format_to_year_week = lambda d: "_".join([str(d.year), str(d.week)])

out_weeks = out_periods.map(format_to_year_week)

#%%
format_to_year_week_2 = lambda d: "_".join([str(d.isocalendar()[0]),
                                            str(d.isocalendar()[1])])

model_data["year_week"] =model_data.pickup_date.apply(format_to_year_week_2)

model_data = model_data.loc[~model_data.year_week.isin(out_weeks)]

#%%
model_data["month"] = model_data.pickup_date.apply(lambda d: d.strftime("%b"))
model_data["wday"] = model_data.pickup_date.apply(lambda d: d.strftime("%a"))

model_data = model_data.drop(["pickup_date", "year_week"], axis=1)

#%%
y = model_data.target
X = model_data.drop(["target"], axis=1)

categorical_cols = [cname for cname in X if X[cname].dtype == "object"]

from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder

# Preprocessing for categorical data
categorical_transformer = Pipeline(steps=[
    ('onehot', OneHotEncoder(handle_unknown='ignore'))
])

# Bundle preprocessing for numerical and categorical data
preprocessor = ColumnTransformer(
    transformers=[
        ('cat', categorical_transformer, categorical_cols)
    ])

from sklearn.ensemble import RandomForestRegressor

model = RandomForestRegressor(n_estimators=100, random_state=1234)

from sklearn.metrics import mean_squared_error

# Bundle preprocessing and modeling code in a pipeline
my_pipeline = Pipeline(steps=[('preprocessor', preprocessor),
                              ('model', model)
                             ])

from sklearn.model_selection import cross_val_score

# Multiply by -1 since sklearn calculates *negative* MAE
scores = -1 * cross_val_score(my_pipeline, X, y,
                              cv=10,
                              scoring='neg_root_mean_squared_error')

print("RMSE scores:\n", scores)
print("Average RMSE score (across experiments):")
print(scores.mean())