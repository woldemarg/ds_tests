# %%
from sklearn.model_selection import train_test_split
from sklearn.metrics import roc_auc_score
from xgboost import XGBClassifier

import pandas as pd
import numpy as np

# %%
data = pd.read_csv("data/samples/app_samp.csv.gz",
                   index_col=0,
                   compression="gzip")

desc = pd.read_csv("data/raw/HomeCredit_columns_description.csv",
                   index_col=0,
                   quotechar='"')

# %%
univ = pd.Series(data=[data[col].nunique()
                       if data[col].dtype == "object"
                       else np.nan
                       for col in data.columns],
                 index=data.columns)

stats = pd.concat([data.dtypes,
                   univ,
                   data.isna().mean().round(4)],
                  axis=1)

stats.columns = ["type", "univ", "pct_nan"]

# %%
data.set_index("SK_ID_CURR",
               drop=True,
               inplace=True)

X = data.drop(["TARGET"], axis=1)
y = data["TARGET"]

X_train, X_test, y_train, y_test = train_test_split(X,
                                                    y,
                                                    test_size=0.2,
                                                    train_size=0.8,
                                                    random_state=1234,
                                                    stratify=data["TARGET"])

X_train = X_train.copy()
X_test = X_test.copy()

# %%
cols_to_impute_w_null = ["AMT_GOODS_PRICE",
                         "OBS_30_CNT_SOCIAL_CIRCLE",
                         "DEF_30_CNT_SOCIAL_CIRCLE",
                         "OBS_60_CNT_SOCIAL_CIRCLE",
                         "DEF_60_CNT_SOCIAL_CIRCLE",
                         "OWN_CAR_AGE",
                         "AMT_REQ_CREDIT_BUREAU_HOUR",
                         "AMT_REQ_CREDIT_BUREAU_DAY",
                         "AMT_REQ_CREDIT_BUREAU_WEEK",
                         "AMT_REQ_CREDIT_BUREAU_MON",
                         "AMT_REQ_CREDIT_BUREAU_QRT",
                         "AMT_REQ_CREDIT_BUREAU_YEAR"]

# for col in cols_to_impute_w_null:
#     X_train.loc[:, col + "_was_missing"] = X_train[col].isnull() * 1
#     X_test.loc[:, col + "_was_missing"] = X_test[col].isnull() * 1

X_train.loc[:, cols_to_impute_w_null] = (X_train[cols_to_impute_w_null]
                                         .fillna(0, axis=1))

X_test.loc[:, cols_to_impute_w_null] = (X_test[cols_to_impute_w_null]
                                        .fillna(0, axis=1))

# %%
X_test.loc[:, "NAME_TYPE_SUITE"] = (X_test["NAME_TYPE_SUITE"]
                                    .fillna(X_train["NAME_TYPE_SUITE"]
                                            .mode()[0]))

X_train.loc[:, "NAME_TYPE_SUITE"] = (X_train["NAME_TYPE_SUITE"]
                                     .fillna(X_train["NAME_TYPE_SUITE"]
                                             .mode()[0]))

# %%
apartments_cols = data.columns[data.columns
                               .str.endswith(("_AVG", "_MODE", "_MEDI"))]

X_train["APART_DESC_INTEGRITY"] = (1 - X_train[apartments_cols]
                                   .isnull().mean(axis=1))

X_test["APART_DESC_INTEGRITY"] = (1 - X_test[apartments_cols]
                                  .isnull().mean(axis=1))

# %%
ext_source_cols = data.columns[data.columns
                               .str.startswith("EXT_")]


def get_ext_score(row):
    if row[ext_source_cols].isnull().sum() == 3:
        return 0
    return (row[ext_source_cols]
            .mean() *
            (1 - row[ext_source_cols]
             .isnull().mean()))


X_train["EXT_SOURCE_INTEGRITY"] = X_train.apply(get_ext_score, axis=1)
X_test["EXT_SOURCE_INTEGRITY"] = X_test.apply(get_ext_score, axis=1)

# %%
occu_gr_cols = ["NAME_INCOME_TYPE",
                "NAME_EDUCATION_TYPE",
                "CODE_GENDER",
                "ORGANIZATION_TYPE"]

occupations = (X_train
               .groupby(occu_gr_cols)["OCCUPATION_TYPE"]
               .apply(lambda d: d.value_counts(dropna=False).index[0])
               .replace(np.nan, "Missed"))

X_train.reset_index(inplace=True)
X_train.set_index(occu_gr_cols, inplace=True)
X_train.update(occupations)
X_train.reset_index(inplace=True)
X_train.set_index(["SK_ID_CURR"], inplace=True)

X_test.reset_index(inplace=True)
X_test.set_index(occu_gr_cols, inplace=True)
X_test.update(occupations)
X_test.reset_index(inplace=True)
X_test.set_index(["SK_ID_CURR"], inplace=True)

# %%
exp_gr_cols = ["ORGANIZATION_TYPE", "OCCUPATION_TYPE"]

exp_gr_range = (X_train
                .groupby(exp_gr_cols)["DAYS_EMPLOYED"]
                .agg(["min", "max"]))

exp_gr_range.columns = ["EXP_GR_MAX", "EXP_GR_MIN"]

X_train = (X_train
           .merge(exp_gr_range,
                  how="left",
                  left_on=exp_gr_cols,
                  right_index=True))

X_test = (X_test
          .merge(exp_gr_range,
                 how="left",
                 left_on=exp_gr_cols,
                 right_index=True))


def normalize_exp(row):
    if row["EXP_GR_MAX"] == row["EXP_GR_MIN"]:
        return 0
    return ((row["DAYS_EMPLOYED"] - row["EXP_GR_MIN"]) /
            (row["EXP_GR_MAX"] - row["EXP_GR_MIN"]))


X_train["DAYS_EMPLOYED_GR_NORM"] = X_train.apply(normalize_exp,
                                                 axis=1)

X_test["DAYS_EMPLOYED_GR_NORM"] = X_test.apply(normalize_exp,
                                               axis=1)

# %%
X_train = X_train.eval("ANNUITY_RATIO = AMT_ANNUITY / AMT_INCOME_TOTAL")
X_test = X_test.eval("ANNUITY_RATIO = AMT_ANNUITY / AMT_INCOME_TOTAL")

X_train = X_train.eval("GOODS_RATIO = AMT_GOODS_PRICE / AMT_CREDIT")
X_test = X_test.eval("GOODS_RATIO = AMT_GOODS_PRICE / AMT_CREDIT")

# %%
cols_to_drop = (apartments_cols.tolist() +
                ext_source_cols.tolist() +
                exp_gr_range.columns.tolist())

X_train.drop(cols_to_drop,
             axis=1,
             inplace=True)

X_test.drop(cols_to_drop,
            axis=1,
            inplace=True)

# %%
X_train = pd.get_dummies(X_train)
X_test = pd.get_dummies(X_test)

X_train, X_test = X_train.align(X_test, join="left", axis=1)

# %%
target = y_train.value_counts()
spw = target[0] / target[1]

xgb_model = XGBClassifier(random_state=1234,
                          objective="binary:logistic",
                          scale_pos_weight=spw,
                          n_jobs=-1)

xgb_model.fit(X_train, y_train)

y_pred = xgb_model.predict(X_test)

print("ROC-AUC on test: {}".format(roc_auc_score(y_test, y_pred)))

# %%
xgb_fea_imp = (pd.DataFrame(list(xgb_model.get_booster()
                                 .get_fscore().items()),
                            columns=["feature", "importance"])
               .sort_values("importance", ascending=False))
