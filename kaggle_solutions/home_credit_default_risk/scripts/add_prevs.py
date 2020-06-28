# %%
import itertools
import pandas as pd
import numpy as np

# %%
desc = pd.read_csv("kaggle_solutions/home_credit_default_risk/data/raw/HomeCredit_columns_description.csv",
                   index_col=0,
                   quotechar='"')

# %%
apps = pd.read_csv("kaggle_solutions/home_credit_default_risk/data/samples/app_samp.csv.gz",
                   index_col=0,
                   compression="gzip")

# %%
pos_cash_balance = pd.read_csv("kaggle_solutions/home_credit_default_risk/data/samples/ps_bal_samp.csv.gz",
                               index_col=0)

# %%
credit_card_balance = pd.read_csv("kaggle_solutions/home_credit_default_risk/data/samples/cc_bal_samp.csv.gz",
                                  index_col=0)

# %%
previous_application = pd.read_csv("kaggle_solutions/home_credit_default_risk/data/samples/prev_app_samp.csv.gz",
                                   index_col=0)

# %%
installments_payments = pd.read_csv("kaggle_solutions/home_credit_default_risk/data/samples/in_pay_samp.csv.gz",
                                    index_col=0)

# %%
def get_stats(df):
    univ = pd.Series(data=[df[col].nunique()
                           if df[col].dtype == "object"
                           else np.nan
                           for col in df.columns],
                     index=df.columns)
    stats = pd.concat([df.dtypes,
                       univ,
                       df.isna().mean().round(4)],
                      axis=1)
    stats.columns = ["type", "univ", "pct_nan"]
    return stats

# %%
previous_application_stats = get_stats(previous_application)

# %%
contract_types = (previous_application["NAME_CONTRACT_TYPE"]
                  .unique()
                  .tolist())

tables_names = ["pos_cash_balance",
                "credit_card_balance",
                "installments_payments"]


def make_intertable(rows, cols):
    ls = []
    for t in list(itertools
                  .product(rows, cols)):
        b = (globals()[t[1]]["SK_ID_PREV"]
             .isin(previous_application
                   .loc[previous_application["NAME_CONTRACT_TYPE"] == t[0],
                        "SK_ID_PREV"]).any())
        ls.append(b)
    out = pd.DataFrame(data=(np.array(ls)
                             .reshape(len(rows),
                                      len(cols))),
                       index=rows,
                       columns=cols)
    return out


intertable = make_intertable(rows=contract_types,
                             cols=tables_names)

# %%
