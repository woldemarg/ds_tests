# %%
from sklearn.metrics import roc_auc_score
from xgboost import XGBClassifier

import pandas as pd
import numpy as np

# %%
apps = pd.read_csv("kaggle_solutions/home_credit_default_risk/data/samples/app_samp.csv.gz",
                   index_col=0,
                   compression="gzip")

# %%
desc = pd.read_csv("kaggle_solutions/home_credit_default_risk/data/raw/HomeCredit_columns_description.csv",
                   index_col=0,
                   quotechar='"')

# %%
bureau = pd.read_csv("kaggle_solutions/home_credit_default_risk/data/samples/bur_samp.csv.gz",
                     index_col=0)

# %%
bureau_balance = pd.read_csv("kaggle_solutions/home_credit_default_risk/data/samples/bur_bal_samp.csv.gz",
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
bureau_stats = get_stats(bureau)

# %%
bureau_mod = bureau.copy()

closed = (bureau_balance
          .groupby("SK_ID_BUREAU")
          .filter(lambda d: (d["STATUS"] == "C").any())["SK_ID_BUREAU"]
          .unique())

bureau_mod["CREDIT_ACTIVE"] = [v if v != "Active" or i not in closed
                               else "Closed" for v, i in
                               list(zip(bureau_mod["CREDIT_ACTIVE"],
                                        bureau_mod["SK_ID_BUREAU"]))]

# %%
(bureau_mod["DAYS_CREDIT_ENDDATE"]
 .fillna(bureau_mod["DAYS_ENDDATE_FACT"],
         inplace=True))

#(bureau_mod
# .dropna(subset=["DAYS_CREDIT_ENDDATE"],
#         inplace=True))

# %%
def get_loan_balance(df):
    out = df.loc[(df["CREDIT_ACTIVE"] == "Active") &
                 (df["DAYS_CREDIT_ENDDATE"] > 0), :].copy()

    return ((out["DAYS_CREDIT_ENDDATE"] /
             (out["DAYS_CREDIT"].abs() +
              out["DAYS_CREDIT_ENDDATE"]) *
             out["AMT_CREDIT_SUM"]).sum())


bureau_mod_gr = bureau_mod.groupby("SK_ID_CURR")

bureau_curr = pd.DataFrame(index=apps["SK_ID_CURR"])

bureau_curr["loan_num"] = bureau_mod_gr.size()

bureau_curr["loan_act"] = (bureau_mod_gr
                           .apply(lambda d:
                                  (d["CREDIT_ACTIVE"] == "Active").sum()))

bureau_curr["loan_ovd"] = (bureau_mod_gr
                           .apply(lambda d:
                                  (d["CREDIT_DAY_OVERDUE"] != 0).sum()))

bureau_curr["loan_bal"] = (bureau_mod_gr
                           .apply(get_loan_balance))

bureau_curr.fillna(0,
                   axis=0,
                   inplace=True)

bureau_curr.to_csv("kaggle_solutions/home_credit_default_risk/derived/bureau_curr.csv")

# %%
X_train = pd.read_csv("kaggle_solutions/home_credit_default_risk/derived/X_train.csv",
                      index_col=0)

X_test = pd.read_csv("kaggle_solutions/home_credit_default_risk/derived/X_test.csv",
                     index_col=0)

y_train = pd.read_csv("kaggle_solutions/home_credit_default_risk/derived/y_train.csv",
                      index_col=0)

y_test = pd.read_csv("kaggle_solutions/home_credit_default_risk/derived/y_test.csv",
                     index_col=0)

# %%
X_train_plus = X_train.join(bureau_curr)
X_test_plus = X_test.join(bureau_curr)

(X_train_plus
.to_csv("kaggle_solutions/home_credit_default_risk/derived/X_train_plus.csv"))
(X_test_plus
.to_csv("kaggle_solutions/home_credit_default_risk/derived/X_test_plus.csv"))

target = y_train["TARGET"].value_counts()
spw = target[0] / target[1]

xgb_model = XGBClassifier(random_state=1234,
                          objective="binary:logistic",
                          scale_pos_weight=spw,
                          n_jobs=-1)

xgb_model.fit(X_train_plus, y_train["TARGET"])

y_pred = xgb_model.predict(X_test_plus)

print("ROC-AUC on test: {}".format(roc_auc_score(y_test, y_pred)))
