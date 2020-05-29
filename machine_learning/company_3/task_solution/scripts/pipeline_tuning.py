# %%
import sys
sys.path.append("machine_learning/company_3/task_solution/scripts")

import pandas as pd
import joblib
import matplotlib.pyplot as plt
import transformers as tr

from sklearn.model_selection import GridSearchCV
from sklearn.model_selection import learning_curve

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
model_pipe = joblib.load("machine_learning/company_3/task_solution/derived/model_pipe.sav")

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
                      xgb_model__learning_rate=0.1)

# %%
train_sizes, train_scores, validation_scores = learning_curve(
    estimator=model_pipe,
    X=X_sample,
    y=y_sample,
    scoring="roc_auc",
    n_jobs=-1,
    random_state=1234)

train_scores_mean = train_scores.mean(axis=1)
validation_scores_mean = validation_scores.mean(axis=1)

plt.figure()
plt.plot(train_sizes,
         train_scores_mean,
         label="train")
plt.plot(train_sizes,
         validation_scores_mean,
         label="test")
plt.legend()
plt.xlabel("training set size")
plt.ylabel("ROC-AUC")
plt.ylim(0.8, 1.05)
plt.show()

plt.savefig("machine_learning/company_3/task_solution/derived/model_learning_curve.png")

# %%
joblib.dump(model_pipe, "machine_learning/company_3/task_solution/results/model_pipe_tuned.sav")
