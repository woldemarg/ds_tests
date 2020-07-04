# %%
import itertools
import re

from sklearn.metrics import roc_auc_score
from xgboost import XGBClassifier

import pandas as pd
import numpy as np

# %%
desc = pd.read_csv("kaggle_solutions/home_credit_default_risk/data/raw/HomeCredit_columns_description.csv",
                   index_col=0,
                   quotechar='"')

# %%
data = pd.read_csv("kaggle_solutions/home_credit_default_risk/data/samples/app_samp.csv.gz",
                   index_col=0,
                   compression="gzip")

data.set_index("SK_ID_CURR",
               drop=True,
               inplace=True)

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
# psb_term = (pos_cash_balance
#             .groupby("SK_ID_PREV")
#             .apply(lambda d:
#                    d.loc[d["NAME_CONTRACT_STATUS"] == "Completed",
#                          "MONTHS_BALANCE"].max() * 30)
#             .rename("DAYS_TERM_UPD"))

# p_apps_mod = pd.merge(left=p_apps_mod,
#                       right=psb_term,
#                       how="left",
#                       left_on="SK_ID_PREV",
#                       right_index=True)

# p_apps_mod["DAYS_TERMINATION"] = [max(t) for t in
#                                   list(zip(p_apps_mod["DAYS_TERMINATION"],
#                                            p_apps_mod["DAYS_TERM_UPD"]))]

# p_apps_mod.drop(["DAYS_TERM_UPD"],
#                 axis=1,
#                 inplace=True)

# %%
overdued = (installments_payments
            .groupby("SK_ID_PREV")
            .apply(lambda d:
                   (d[d["DAYS_ENTRY_PAYMENT"] > d["DAYS_INSTALMENT"]]
                    .sum())
                   .any())
            .rename("is_overdued"))

p_apps_mod = pd.merge(left=p_apps_mod,
                      right=overdued,
                      how="left",
                      left_on="SK_ID_PREV",
                      right_index=True)

# %%
exceeded = (credit_card_balance
            .groupby("SK_ID_PREV")
            .apply(lambda d:
                   (d[d["AMT_BALANCE"] > d["AMT_CREDIT_LIMIT_ACTUAL"]]
                    .astype("bool")
                    .sum())
                   .any())
            .rename("limit_exceeded"))

p_apps_mod = pd.merge(left=p_apps_mod,
                      right=exceeded,
                      how="left",
                      left_on="SK_ID_PREV",
                      right_index=True)

# %%
(p_apps_mod
 .groupby("SK_ID_CURR")["NAME_CONTRACT_TYPE"]
 .nunique()
 .value_counts(normalize=True))

# %%
p_apps_mod_gr = p_apps_mod.groupby("SK_ID_CURR")

p_apps_curr = pd.DataFrame(index=data.index)

p_apps_curr["hc_loan_num"] = (p_apps_mod_gr
                              .apply(lambda d:
                                     (d["NAME_CONTRACT_STATUS"] == "Approved")
                                     .sum()))

p_apps_curr["hc_loan_num_type"] = (p_apps_mod_gr
                                   .apply(lambda d:
                                          ((d["NAME_CONTRACT_STATUS"] ==
                                            "Approved") & (d["NAME_CONTRACT_TYPE"] ==
                                                           data.at[d["SK_ID_CURR"]
                                                                   .iloc[0],
                                                                   "NAME_CONTRACT_TYPE"]))
                                          .sum()))

p_apps_curr["hc_ref_num"] = (p_apps_mod_gr
                             .apply(lambda d:
                                    (d["NAME_CONTRACT_STATUS"] == "Refused")
                                    .sum()))

p_apps_curr["hc_ref_num_type"] = (p_apps_mod_gr
                                  .apply(lambda d:
                                         ((d["NAME_CONTRACT_STATUS"] ==
                                           "Refused") & (d["NAME_CONTRACT_TYPE"] ==
                                                         data.at[d["SK_ID_CURR"]
                                                                 .iloc[0],
                                                                 "NAME_CONTRACT_TYPE"]))
                                         .sum()))

p_apps_curr["hc_loan_ovd"] = (p_apps_mod_gr
                              .apply(lambda d:
                                     ((d["NAME_CONTRACT_STATUS"] == "Approved") &
                                      (d["is_overdued"]))
                                     .sum()))

p_apps_curr["hc_loan_ovd_type"] = (p_apps_mod_gr
                                   .apply(lambda d:
                                          ((d["NAME_CONTRACT_STATUS"] ==
                                            "Approved") & (d["is_overdued"]) &
                                           (d["NAME_CONTRACT_TYPE"] ==
                                            data.at[d["SK_ID_CURR"]
                                                    .iloc[0],
                                                    "NAME_CONTRACT_TYPE"]))
                                          .sum()))

p_apps_curr["hc_loan_amt"] = (p_apps_mod_gr
                              .apply(lambda d:
                                     d.loc[d["NAME_CONTRACT_STATUS"] ==
                                           "Approved",
                                           "AMT_CREDIT"].sum()))

p_apps_curr["hc_loan_amt_type"] = (p_apps_mod_gr
                                   .apply(lambda d:
                                          d.loc[(d["NAME_CONTRACT_STATUS"] ==
                                                 "Approved") &
                                                (d["NAME_CONTRACT_TYPE"] ==
                                                 data.at[d["SK_ID_CURR"]
                                                         .iloc[0],
                                                         "NAME_CONTRACT_TYPE"]),
                                                "AMT_CREDIT"].sum()))

p_apps_curr["has_lim_exceeded"] = (p_apps_mod_gr
                                   .apply(lambda d:
                                          ((d["NAME_CONTRACT_STATUS"] ==
                                            "Approved") & (d["limit_exceeded"]))
                                          .sum()))

# p_apps_curr["has_occ_changed"] = (p_apps_mod_gr
#                                   .apply(lambda d:
#                                          0 if data.at[d["SK_ID_CURR"]
#                                                       .iloc[0],
#                                                       "DAYS_EMPLOYED"] >
#                                          d["DAYS_DECISION"].max() or
#                                          data.at[d["SK_ID_CURR"]
#                                                  .iloc[0],
#                                                  "DAYS_EMPLOYED"] == 365243
#                                          else 1))

p_apps_curr.fillna(0,
                   axis=0,
                   inplace=True)

p_apps_curr.to_csv("kaggle_solutions/home_credit_default_risk/derived/p_apps_curr.csv")

# %%
X_train_plus = pd.read_csv("kaggle_solutions/home_credit_default_risk/derived/X_train_plus.csv",
                           index_col=0)

X_test_plus = pd.read_csv("kaggle_solutions/home_credit_default_risk/derived/X_test_plus.csv",
                          index_col=0)

y_train = pd.read_csv("kaggle_solutions/home_credit_default_risk/derived/y_train.csv",
                      index_col=0)

y_test = pd.read_csv("kaggle_solutions/home_credit_default_risk/derived/y_test.csv",
                     index_col=0)

# %%
X_train_pp = X_train_plus.join(p_apps_curr)
X_test_pp = X_test_plus.join(p_apps_curr)

# %%
col_ls = ["AMT_INCOME_TOTAL",
          "AMT_CREDIT",
          "AMT_ANNUITY",
          "AMT_GOODS_PRICE",
          "loan_bal",
          "hc_loan_amt",
          "hc_loan_amt_type"]

col_bins = {}

for col in col_ls:
    vals, bins = pd.qcut(x=X_train_pp[col],
                         q=50,
                         duplicates="drop",
                         precision=0,
                         retbins=True)
    col_bins.update({col: bins})
    X_train_pp[col] = pd.cut(X_train_pp[col],
                             col_bins[col])
    X_test_pp[col] = pd.cut(X_test_pp[col],
                            col_bins[col])

X_train_pp = pd.get_dummies(X_train_pp)
X_test_pp = pd.get_dummies(X_test_pp)

X_train_pp, X_test_pp = X_train_pp.align(X_test_pp, join="left", axis=1)

# %%
regex = re.compile(r"\[|\]|<", re.IGNORECASE)

X_train_pp.columns = [regex.sub("_", col)
                      if any(x in str(col) for x in set(("[", "]", "<")))
                      else col for col in X_train_pp.columns.values]

X_test_pp.columns = X_train_pp.columns

# %%
target = y_train["TARGET"].value_counts()
spw = target[0] / target[1]

xgb_model = XGBClassifier(random_state=1234,
                          objective="binary:logistic",
                          scale_pos_weight=spw,
                          n_jobs=-1)

xgb_model.fit(X_train_pp, y_train["TARGET"])

y_pred = xgb_model.predict(X_test_pp)

print("ROC-AUC on test: {}".format(roc_auc_score(y_test, y_pred)))
