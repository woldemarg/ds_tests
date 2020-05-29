# %%
import sys
sys.path.append("machine_learning/company_3/task_solution/scripts")

import pandas as pd
import joblib
import transformers as tr

from xgboost import XGBClassifier
from sklearn.model_selection import cross_val_score
from sklearn.pipeline import Pipeline

# %%
sample = (pd.read_csv("machine_learning/company_3/task_solution/derived/sample.csv")
          .drop(["id"], axis=1))

# %%
cat_cols = sample.columns[sample.columns.str.startswith("cat")]
sample.loc[:, cat_cols] = sample[cat_cols].astype(str)

# %%
y_sample = sample["gb"]
X_sample = sample.copy()

# %%
xgb_model = joblib.load("machine_learning/company_3/task_solution/derived/base_model.sav")

# %%
feature_selection = Pipeline(
    steps=[
        ("drop_initial", tr.DropColumnsTransformer()),
        ("impute_cats", tr.CustomImputer(strategy="mode")),
        ("impute_nums", tr.CustomImputer(strategy="mean")),
        ("encode_oh", tr.CustomOHEncoder()),
        ("drop_low_corr", tr.CorrelationTransformer())])

model_pipe = Pipeline(
    steps=[
        ("f_selection", feature_selection),
        ("xgb_model", xgb_model)])

# %%
roc_auc_sample = cross_val_score(model_pipe,
                                 X_sample,
                                 y_sample,
                                 scoring="roc_auc",
                                 n_jobs=-1)

print("ROC_AUC on CV: {} ({})".format(roc_auc_sample.mean(),
                                      roc_auc_sample.std()))

# %%
joblib.dump(model_pipe, "machine_learning/company_3/task_solution/derived/model_pipe.sav")
