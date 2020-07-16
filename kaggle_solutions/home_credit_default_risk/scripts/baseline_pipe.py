# %%
import sys
sys.path.append("kaggle_solutions/home_credit_default_risk/scripts")

from sklearn.pipeline import Pipeline
from sklearn.model_selection import cross_val_score, GridSearchCV

from xgboost import XGBClassifier

import pandas as pd

import custom_transformers as tr

# %%
data = pd.read_csv("kaggle_solutions/home_credit_default_risk/data/samples/app_samp.csv.gz",
                   index_col=0,
                   compression="gzip")

data.set_index("SK_ID_CURR",
               drop=True,
               inplace=True)

data["DAYS_EMPLOYED"].replace({365243: -1}, inplace=True)
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

apartments_cols = data.columns[data.columns
                               .str.endswith(("_AVG", "_MODE", "_MEDI"))]

ext_source_cols = data.columns[data.columns
                               .str.startswith("EXT_")]

occu_gr_cols = ["NAME_INCOME_TYPE",
                "NAME_EDUCATION_TYPE",
                "CODE_GENDER",
                "ORGANIZATION_TYPE"]

exp_gr_cols = ["ORGANIZATION_TYPE", "OCCUPATION_TYPE"]

cols_to_drop = (apartments_cols.tolist() +
                ext_source_cols.tolist() +
                ["mean", "std", "zscore"])

# %%
target = data["TARGET"].value_counts()

spw = target[0] / target[1]

xgb_model = XGBClassifier(random_state=1234,
                          objective="binary:logistic",
                          scale_pos_weight=spw,
                          n_jobs=-1)

model_pipe = Pipeline(
    steps=[
        ("impute_nums", tr.CustomImputer(strategy="constant",
                                         cols=cols_to_impute_w_null)),
        ("impute_cats", tr.CustomImputer(strategy="mode",
                                        cols="NAME_TYPE_SUITE")),
        ("get_ext_source_integrity", tr.ExtSourceIntegrity(ext_source_cols)),
        ("impute_occupations", tr.OccupationsImputer(occu_gr_cols)),
        ("normalize_days_employed", tr.DaysEmployedZscore(exp_gr_cols)),
        ("discretizing_zscore", tr.ZscoreQuantileDiscretizer()),
        ("get_apart_desc_integrity", tr.SimpleColumnsAdder(apartments_cols,
                                                           cols_to_drop)),
        ("oh_encoding", tr.CustomOHEncoder()),
        ("xgb_model", xgb_model)])

# %%
y_sample = data["TARGET"]
X_sample = data.drop(["TARGET"], axis=1).copy()

print(cross_val_score(model_pipe,
                      X_sample,
                      y_sample,
                      scoring="roc_auc")
      .mean())

# %%
param_grid = {"xgb_model__n_estimators": [500, 750, 1000],
              "xgb_model__learning_rate": [0.001, 0.01, 0.1]}

search_cv = GridSearchCV(model_pipe,
                         param_grid=param_grid,
                         scoring="roc_auc",
                         n_jobs=-1)

search_cv.fit(X_sample, y_sample)

print("Best ROC-AUC on CV: {}:".format(search_cv.best_score_))
print(search_cv.best_params_)

# %%
model_pipe.set_params(xgb_model__n_estimators=1000,
                      xgb_model__learning_rate=0.001)

# %%
model_pipe.fit(X_sample, y_sample)

xgb_fea_imp = (pd.DataFrame(list(model_pipe.steps[-1][-1].get_booster()
                                 .get_fscore().items()),
                            columns=["feature", "importance"])
               .sort_values("importance", ascending=False))
