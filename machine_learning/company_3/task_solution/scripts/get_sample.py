# %%
import pandas as pd
from sklearn.model_selection import StratifiedShuffleSplit

# %%
train_df = (pd.read_csv("D:/py_ml/ds_tests/machine_learning/company_3/task_solution/data/train_df.csv",
                        sep="\t",
                        index_col=0)
            .reset_index(drop=True))

# %%
train_df["gb"].value_counts()

# %%
strata_split = StratifiedShuffleSplit(n_splits=1,
                                      test_size=0.25,
                                      random_state=1234)

for train_idx, test_idx in strata_split.split(train_df,
                                              train_df["gb"]):
    train_sample = train_df.reindex(test_idx)

# %%
train_sample["gb"].value_counts()

# %%
train_sample.to_csv("D:/py_ml/ds_tests/machine_learning/company_3/task_solution/derived/sample.csv",
                    index=False)
