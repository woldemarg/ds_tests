# %%
import sys
sys.path.append("machine_learning/company_3/task_solution/scripts")

import pandas as pd
import joblib
import transformers as tr

# %%
train_df = (pd.read_csv("machine_learning/company_3/task_solution/data/train_df.csv",
                        sep="\t",
                        index_col=0)
            .reset_index(drop=True))

delay_df = pd.read_csv("machine_learning/company_3/task_solution/data/delay_df.csv",
                       sep="\t",
                       index_col=0)

# %%
def cats_to_obj(*dfs):
    out = []
    for df in dfs:
        cat_cols = df.columns[df.columns.str.startswith("cat")]
        df.loc[:, cat_cols] = df[cat_cols].astype(str)
        out.append(df)
    return tuple(out)

train_mod, delay_mod = cats_to_obj(train_df, delay_df)

# %%
y_train = train_mod["gb"]
X_train = (train_mod
           .drop(["id"], axis=1)
           .copy())

X_delay = (delay_mod
           .drop(["id"], axis=1)
           .copy())

# %%
model_pipe = joblib.load("machine_learning/company_3/task_solution/results/model_pipe_tuned.sav")

# %%
model_pipe.fit(X_train, y_train)

delay_pred = (delay_df
              .assign(gb=model_pipe.
                      predict_proba(X_delay)[:, 1]))
# %%
delay_pred.to_csv("machine_learning/company_3/task_solution/results/delay_df.csv",
                    index=True)
