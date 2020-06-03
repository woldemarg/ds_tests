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
    return rate_old, rate_new, norm.cdf(z_score)

# %%
def print_ab_results(data,
                     key,
                     strategy="periods",
                     freq="1M",
                     param_list=[]):
    if strategy == "periods":
        groups = (data
                  .groupby(["experiment_mobile_checkout_theme",
                            pd.Grouper(key="date", freq=freq)],
                           sort=False)[key])
    elif strategy == "features":
        groups = data.groupby(param_list,
                              sort=False)[key]

    groupped = (groups
                .agg(["sum", "size"])
                .sort_index(level=-1,
                            sort_remaining=True,
                            ascending=False))

    if len(param_list) == 0 or len(param_list) > 1:
        for idx, df_select in groupped.groupby(level=-1, axis=0):
            rate_A, rate_B, conf = get_confidence_ab(df_select)
            if rate_B <= rate_A:
                print("Seems like B performs worser on {}\n."
                      .format(key))
            else:
                print("A conversion rate as for '{i}' estimated by '{k}' is {a:.3}.\nB conversion rate as for '{i}' estimated by '{k}' is {b:.3}.\nDifference is significant with {c:.2%} confidence.\n\n"""
                      .format(i=idx, k=key, a=rate_A, b=rate_B, c=conf))
    else:
        rate_A, rate_B, conf = get_confidence_ab(groupped)
        print("A conversion rate estimated by '{k}' is {a:.3}.\nB conversion rate estimated by '{k}' is {b:.3}.\nDifference is significant with {c:.2%} confidence.\n\n"""
                      .format(k=key, a=rate_A, b=rate_B, c=conf))

# %%
print_ab_results(data=exp_data,
                 key="transaction_try",
                 strategy="features",
                param_list=["experiment_mobile_checkout_theme"])
