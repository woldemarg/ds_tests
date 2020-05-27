# %%
import numpy as np
import pandas as pd

from xgboost import XGBClassifier
from sklearn.metrics import roc_auc_score

# %%
sample = (pd.read_csv("D:/py_ml/ds_tests/machine_learning/company_3/task_solution/derived/sample.csv")
          .drop(["id"], axis=1))

y_sample = sample["gb"]
X_sample = sample.copy()

# %%
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(X_sample,
                                                    y_sample,
                                                    test_size=0.2,
                                                    random_state=1234,
                                                    stratify=y_sample)

# %%
th_nans = 0.35
th_high_cardinality = 10
th_low_variance = 0.1
th_corr = 0.05

# %%
cols_nans = (X_train
            .columns[X_train.isna().mean() > th_nans]
            .tolist())

# %%
cats = X_train.columns[X_train.columns.str.startswith("cat")]

X_train.loc[:, cats] = X_train[cats].astype(str)
X_test.loc[:, cats] = X_test[cats].astype(str)

# %%
cols_high_cardinality = (cats[X_train[cats]
                              .nunique() > th_high_cardinality]
                         .tolist())

# %%
cols_to_drop_init = list(set(cols_nans) | set(cols_high_cardinality))

# %%
X_train = X_train.drop(cols_to_drop_init, axis=1)
X_test = X_test.drop(cols_to_drop_init, axis=1)

# %%
cats_left = X_train.select_dtypes(include="object").columns.tolist()
nums_left = X_train.select_dtypes(include=np.number).columns.tolist()

# %%
X_train.loc[:, cats_left] = (X_train[cats_left]
                             .fillna(X_train[cats_left].mode()))

X_test.loc[:, cats_left] = (X_test[cats_left]
                             .fillna(X_train[cats_left].mode()))

# %%
X_train.loc[:, nums_left] = (X_train[nums_left]
                             .fillna(X_train[nums_left].mean()))

X_test.loc[:, nums_left] = (X_test[nums_left]
                             .fillna(X_train[nums_left].mean()))

# %%
print(X_train.isna().sum().sum()); print(X_test.isna().sum().sum())

# %%
X_train = pd.get_dummies(X_train)
X_test = pd.get_dummies(X_test)

X_train, X_test = X_train.align(X_test,
                                join="left",
                                axis=1,
                                fill_value=0)

# %%
cols_low_std = (X_train
                .columns[(X_train.std() < th_low_variance) &
                         (X_train.columns != "gb")]
                .tolist())

# %%
cols_low_corr = (X_train
                .columns[(X_train.corr().abs()["gb"] < th_corr) &
                         (X_train.columns != "gb")]
                .tolist())

# %%
cols_to_drop_final = list(set(cols_low_std) | set(cols_low_corr))
cols_to_drop_final.append("gb")

# %%
X_train = X_train.drop(cols_to_drop_final, axis=1)
X_test = X_test.drop(cols_to_drop_final, axis=1)

# %%
target = y_train.value_counts()
spw = target[0] / target[1]

xgb_model = XGBClassifier(random_state=1234,
                          objective="reg:squarederror",
                          scale_pos_weight=spw)

xgb_model.fit(X_train, y_train)

print("ROC_AUC on test: {}".format(roc_auc_score(y_test,
                                                 xgb_model.predict(X_test))))
