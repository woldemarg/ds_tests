import pandas as pd
import numpy as np


description = pd.read_csv("data/encoded/columns_description.csv", index_col=0)
description.reset_index(drop=True, inplace=True)


events = pd.read_csv("data/encoded/events_Hokkaido.csv")
holidays = pd.read_csv("data/encoded/holidays_Japan.csv")
weather = pd.read_csv("data/encoded/weather_Hokkaido.csv")


jalan_dcols_to_parse = [5, 6, 7, 10]
jalan = pd.read_csv("data/encoded/jalan_shinchitose.csv",
                    parse_dates=jalan_dcols_to_parse)


rakuten_dcols_to_parse = [4, 6, 16, 19]
rakuten = pd.read_csv("data/encoded/rakuten_shinchitose.csv",
                      parse_dates=rakuten_dcols_to_parse)


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


def extract_date(row):
    """Get date from all date_time
    columns in a given row."""
    row.iloc[1:-1] = row.iloc[1:-1].dt.date
    return row


raw_data = (pd.concat([jalan, rakuten], axis=0)
            .reset_index(drop=True)
            .apply(extract_date, axis=1)
            .rename(columns=(lambda x: x[:-5]
                    if x.endswith('_time') else x)))


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


# model_data.to_csv("derived/model_data_py.csv", index=False)



date_index = pd.date_range(model_data["pickup_date"].min(),
                           model_data["pickup_date"].max(),
                           freq="D")

missed_in_data = (pd.Series(index[~index.isin(model_data["pickup_date"])])
                   .repeat(2))

z = np.repeat(["a", "b"], 3)
np.repeat(3, 4)

series = pd.Series(range(9), index=index)

model_data["pickup_date"] = pd.to_datetime(model_data["pickup_date"])


df_weeks = (model_data
             .groupby(
                 [model_data.pickup_date.dt.strftime('%Y-w%V'),
                 "company_name"])
             .sum()
             .reset_index())


df_weeks_pivoted = pd.pivot_table(df_weeks,
                                  values="target",
                                  index=["pickup_date"],
                                  columns=["company_name"])


df_weeks_pivoted.plot()
