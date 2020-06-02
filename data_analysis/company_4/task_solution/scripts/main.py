# %%
import pandas as pd
import numpy as np
from scipy.stats import norm

# %%
exp_data = pd.read_csv("data_analysis/company_4/Task_solution/data/experiment_raw.csv",
                       parse_dates=["date"])

# %%
def get_confidence_ab(df):
    rate_old = df.iloc[0, 0] / df.iloc[0, 1]
    rate_new = df.iloc[1, 0] / df.iloc[1, 1]
    std_old = np.sqrt(rate_old * (1 - rate_old) / df.iloc[0, 1])
    std_new = np.sqrt(rate_new * (1 - rate_new) / df.iloc[1, 1])
    z_score = (rate_new - rate_old) / np.sqrt(std_old**2 + std_new**2)
    return norm.cdf(z_score)

# %%
def print_ab_results(data,
                     key,
                     strategy="periods",
                     freq="1M",
                     param_list=None):
    if strategy == "periods":
        groups = (data
                  .groupby(["experiment_mobile_checkout_theme",
                            pd.Grouper(key="date", freq=freq)])[key])
    elif strategy == "features":
        groups = data.groupby(param_list)[key]

    groupped = (groups
                .agg(["sum", "size"])
                .sort_index(level=-1,
                            sort_remaining=True,
                            ascending=False))

    for idx, df_select in groupped.groupby(level=-1):
        print("B's conversion as for '{}' estimated by '{}' is better with {:.1%} confidence"
              .format(idx, key, get_confidence_ab(df_select)))

# %%
print_ab_results(data=exp_data,
                 key="transaction_success")
