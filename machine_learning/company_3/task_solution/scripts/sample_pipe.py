# %%
import numpy as np
import pandas as pd

# %%
sample = pd.read_csv("D:/py_ml/ds_tests/machine_learning/company_3/task_solution/derived/sample.csv")

# %%
th_nan = 0.25
cols_nan = (sample
            .columns[sample.isna().mean() > th_nan]
            .tolist())

# %%
categoricals = sample.columns[sample.columns.str.startswith("cat")]

sample[categoricals] = sample[categoricals].astype(str)

th_high_cardinality = 10
cols_high_cardinality = (categoricals[sample[categoricals]
                                      .nunique() > th_high_cardinality]
                         .tolist())

# %%
cols_to_drop_init = list(set(cols_nan) | set(cols_high_cardinality))

# %%
sample_dropped = sample.drop(cols_to_drop_init, axis=1)

# %%
nums_left = sample_dropped.select_dtypes(include=np.number).columns.tolist()
cats_left = sample_dropped.select_dtypes(include="object").columns.tolist()

sample_dropped.loc[:, nums_left] = (sample_dropped[nums_left]
                                    .fillna(sample_dropped[nums_left].mean()))

sample_dropped.loc[:, cats_left] = (sample_dropped[cats_left]
                                    .fillna(sample_dropped[cats_left].mode()))

sample_dropped.isna().sum().sum()

# %%
sample_nums = (pd.get_dummies(sample_dropped)
               .drop(["id"], axis=1))

# %%
th_low_variance = 0.3
sample_hvar = sample_nums.loc[:, (sample_nums.std() > th_low_variance) |
                             (sample_nums.columns == "gb")]

# %%
th_corr = 0.05
sample_corr = sample_hvar.loc[:, sample_hvar.corr().abs()["gb"] > th_corr]

# %%
from sklearn.model_selection import cross_val_score
from xgboost import XGBClassifier

y_class = sample_corr["gb"]
X_class = sample_corr.drop(["gb"], axis=1)

y_count = sample_corr["gb"].value_counts()

spw = y_count[0] / y_count[1]

model_class = XGBClassifier(random_state=1234,
                            objective="reg:squarederror",
                            scale_pos_weight=spw)


roc_auc_sample = cross_val_score(model_class,
                                 X_class,
                                 y_class,
                                 scoring="roc_auc")

print("ROC_AUC: {} ({})".format(roc_auc_sample.mean(),
                             roc_auc_sample.std()))
