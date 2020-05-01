import numpy as np
import pandas as pd

from sklearn.preprocessing import OneHotEncoder

# %%
url = "https://raw.githubusercontent.com/woldemarg/nix_solutions_test/master/task_3/data/Data%20for%20the%20Churn%20task%20_%20BDA%20homework.csv"
data = pd.read_csv(url)

# %%
data.isnull().sum()

# %%
data.nunique()

# %%
data_mod = data.drop(["customerID",
                      "TotalCharges"],
                     axis=1)

binary_cols = (data_mod.columns[(data_mod.nunique() == 2) &
                                (data_mod.apply(
                                    lambda s: all(s.str.contains("Yes|No"))))]
               .tolist())

data_mod.loc[:, binary_cols] = (data_mod[binary_cols]
                                .replace(["Yes", "No"], [1, 0]))

threesome_cols = (data_mod.columns[(data_mod.nunique() == 3) &
                                   (data_mod.apply(
                                       lambda s:
                                       all(s.str.contains("Yes|No"))))]
                  .tolist())

data_mod.loc[:, threesome_cols] = (data_mod[threesome_cols]
                                   .replace({
                                       "Yes":1,
                                       "No":0,
                                       "No phone service":0,
                                       "No internet service":0}))

data_mod.loc[:, "InternetService"] = (data_mod.InternetService
                                      .replace({
                                          "No":0,
                                          "DSL":1,
                                          "Fiber optic":2}))

# %%
cat_cols_left = [col for col in data_mod
                 if data_mod[col].dtype == "object"]

OH_encoder = OneHotEncoder(handle_unknown="error",
                           drop="first", sparse=False)

OH_cols = pd.DataFrame(OH_encoder.fit_transform(data_mod[cat_cols_left]))

OH_cols_names = OH_encoder.get_feature_names(cat_cols_left)
OH_cols.columns = OH_cols_names

OH_cols_index = data_mod.index

num_data = pd.concat([data_mod.drop(cat_cols_left, axis=1), OH_cols],
                     axis=1)

# %%
y = num_data.Churn
X = num_data.drop(["Churn"], axis=1)