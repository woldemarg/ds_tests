# %%
import pandas as pd
from sklearn.model_selection import StratifiedShuffleSplit

# %%
train = (pd.read_csv("D:/py_ml/ds_tests/machine_learning/company_3/task_solution/data/train_df.csv",
                    sep="\t",
                    index_col=0)
         .reset_index(drop=True))

# %%
train.gb.value_counts()

# %%
split = StratifiedShuffleSplit(n_splits=1,
                               test_size=0.2,
                               random_state=1234)

for train_idx, test_idx in split.split(train, train.gb):
    train_sample = train.reindex(test_idx)

# %%
train_sample.gb.value_counts()

# %%
train_sample.to_csv("D:/py_ml/ds_tests/machine_learning/company_3/task_solution/derived/sample.csv",
                    index=False)
