# %%
from xgboost import XGBRegressor

from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import FunctionTransformer, OneHotEncoder
from sklearn.model_selection import KFold, GridSearchCV
from sklearn.compose import ColumnTransformer

from scipy.stats import ttest_ind

import pandas as pd
import numpy as np
import pickle

# import matplotlib.pyplot as plt

from app.helper_funcs import hours_of_daylight, assign_columns, long_holidays

# %%
# plt.style.use("seaborn")

# %%
description = pd.read_csv("data/columns_description.csv", index_col=0)
description.reset_index(drop=True, inplace=True)

# %%
jalan_dcols_to_parse = [5, 6, 7, 10]

jalan = pd.read_csv("data/jalan_shinchitose.csv",
                    parse_dates=jalan_dcols_to_parse)

rakuten_dcols_to_parse = [4, 6, 16, 19]

rakuten = pd.read_csv("data/rakuten_shinchitose.csv",
                      parse_dates=rakuten_dcols_to_parse)

# %%
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
         .assign(is_cancelled=np.invert(np.isnat(jalan
                                                 .cancellation_date_time))
                 .astype(int))
         .loc[:, cols_to_select])

rakuten = (rakuten
           .assign(company_name="rakuten")
           .assign(is_cancelled=np.invert(
               np.isnat(rakuten.cancel_request_date_time)).astype(int))
           .rename(columns={
               "cancel_request_date_time": "cancellation_date_time"})
           .loc[:, cols_to_select])

# %%
raw_data = (pd.concat([jalan, rakuten], axis=0)
            .reset_index(drop=True)
            .rename(columns=(lambda x: x[:-5]
                             if x.endswith("_time") else x)))

raw_data_filtered = (raw_data
                     .loc[(raw_data["pickup_date"] <
                           raw_data["request_date"].max()) &
                          (raw_data.is_cancelled != 1), :]
                     .groupby([pd.Grouper(key="pickup_date",
                                          freq="1D"),
                               "company_name"])
                     .size()
                     .unstack()
                     .fillna(0))

# %%
idx = pd.date_range(raw_data_filtered.index.min(),
                    raw_data_filtered.index.max())

daily = (raw_data_filtered
         .reindex(idx, fill_value=0)
         .stack()
         .reset_index(level=1)
         .rename(columns={0: "target"}))

# %%
d_total = daily.resample("D").sum()
w_total = daily.resample("W").sum()

# %%
# w_total.rolling(4).mean().plot()

# %%
w_total["daylight"] = [*map(hours_of_daylight, w_total.index)]
d_total["daylight"] = [*map(hours_of_daylight, d_total.index)]

# %%
X = w_total[["daylight"]]
y = w_total["target"]

lr = LinearRegression(fit_intercept=True).fit(X, y)

xfit = np.linspace(8, 16)
yfit = lr.predict(xfit[:, np.newaxis])

# plt.scatter(w_total["daylight"], w_total["target"])
# plt.plot(xfit, yfit, "-k")
# plt.xlabel("hours of daylight (seasonal component)")
# plt.ylabel("num of rentals per week")

# %%
d_total["day_of_week"] = d_total.index.dayofweek

d_grouped = d_total.groupby("day_of_week")["target"].mean()
# d_grouped.plot()

# %%
d_total["is_long_holidays"] = long_holidays

# %%
a = d_total[d_total["is_long_holidays"] == 0]["target"]
b = d_total[d_total["is_long_holidays"] == 1]["target"]

stat, p = ttest_ind(a, b)

print("Difference in means is significant with {0:.2%} confidence"
      .format(1-p))

# %%
# from scipy.stats import t

# mean_a, mean_b = a.mean(), b.mean()
# std_a, std_b = a.var(ddof=1), b.var(ddof=1)
# n_a, n_b = len(a), len(b)
# se_a, se_b = np.sqrt(std_a/n_a), np.sqrt(std_b/n_b)
# sed = np.sqrt(se_a**2 + se_b**2)
# t_stat = (mean_a - mean_b) / sed
# df = n_a + n_b - 2
# p_custom = (1 - t.cdf(abs(t_stat), df)) * 2

# print("Difference in means is significant with {0:.2%} confidence"
#       .format(1-p_custom))

# %%
d_total = pd.get_dummies(data=d_total,
                         columns=["day_of_week"],
                         dtype="int64")

X = d_total.drop(["target"], axis=1)
y = d_total["target"]

rfr = RandomForestRegressor().fit(X, y)
d_total["trend"] = rfr.predict(X)
# d_total[["target", "trend"]].plot()

# %%
d_total["trend_corrected"] = (d_total["target"] -
                              d_total["trend"] +
                              d_total["trend"].mean())

print("RMSE about trend: {0:.2f}"
      .format(np.std(d_total["trend_corrected"])))

# d_total["trend_corrected"].plot()

# %%
X_daily = daily.drop(["target"], axis=1).copy()
y_daily = daily["target"]

xgb_model = XGBRegressor(random_state=1234,
                         objective="reg:squarederror",
                         n_jobs=-1)

cols_encoder = ColumnTransformer(
    transformers=[
        ("oh_encoder",
         OneHotEncoder(handle_unknown="ignore",
                       sparse=False),
         ["company_name", "day_of_week"])],
    remainder="passthrough")

model_pipe = Pipeline(
    steps=[
        ("assign_cols", FunctionTransformer(assign_columns)),
        ("encoding_cols", cols_encoder),
        ("xgb_model", xgb_model)])

# %%
param_grid = {"xgb_model__n_estimators": [500, 750, 1000],
              "xgb_model__learning_rate": [0.001, 0.01, 0.1]}

kf = KFold(n_splits=5, shuffle=True, random_state=1234)

search_cv = GridSearchCV(model_pipe,
                         param_grid=param_grid,
                         scoring="neg_root_mean_squared_error",
                         cv=kf,
                         n_jobs=-1)

search_cv.fit(X_daily, y_daily)

print("Best RMSE on CV: {}:".format(-1 * search_cv.best_score_))
print(search_cv.best_params_)

# %%
model_pipe.set_params(xgb_model__n_estimators=500,
                      xgb_model__learning_rate=0.01)

# %%
model_pipe.fit(X_daily, y_daily)

pickle.dump(model_pipe, open("app/model_pipe.pkl", "wb"))
