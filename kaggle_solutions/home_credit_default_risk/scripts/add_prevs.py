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
p_apps = pd.read_csv("kaggle_solutions/home_credit_default_risk/data/samples/prev_app_samp.csv.gz",
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
p_apps_stats = get_stats(p_apps)

# %%
contract_types = (p_apps["NAME_CONTRACT_TYPE"]
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
             .isin(p_apps
                   .loc[p_apps["NAME_CONTRACT_TYPE"] == t[0],
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
p_apps_mod = (p_apps
              .query("FLAG_LAST_APPL_PER_CONTRACT == 'Y'\
                     and NFLAG_LAST_APPL_IN_DAY == '1'")
              .copy())

# %%
psb_term = (pos_cash_balance
            .groupby("SK_ID_PREV")
            .apply(lambda d:
                   d.loc[d["NAME_CONTRACT_STATUS"] == "Completed",
                         "MONTHS_BALANCE"].max() * 30)
            .rename("DAYS_TERM_UPD"))

p_apps_mod = pd.merge(left=previous_application_mod,
                      right=psb_term,
                      how="left",
                      left_on="SK_ID_PREV",
                      right_index=True)

p_apps_mod["DAYS_TERM_UPD"] = [max(t) for t in
                               list(zip(p_apps_mod["DAYS_TERMINATION"],
                                        p_apps_mod["DAYS_TERM_UPD"]))]

# %%
