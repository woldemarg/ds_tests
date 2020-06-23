# %%
from sklearn.base import BaseEstimator
import pandas as pd
import numpy as np

# %%
class SimpleColumnsAdder(BaseEstimator):

    def __init__(self, apartment_cols, cols_to_drop):
        self.apartment_cols = apartment_cols
        self.cols_to_drop = cols_to_drop

    def fit(self, X, y=None, **fit_params):
        return self

    def transform(self, X, **transform_params):
        X["APART_DESC_INTEGRITY"] = (1 - X[self.apartment_cols]
                                     .isnull().mean(axis=1))
        X["GOODS_RATIO"] = (X.apply(lambda row:
                                    0 if np.isnan(row["AMT_GOODS_PRICE"])
                                    else (row["AMT_GOODS_PRICE"] /
                                          row["AMT_CREDIT"]), axis=1))
        X = X.eval("ANNUITY_RATIO = AMT_ANNUITY / AMT_INCOME_TOTAL")

        X = X.drop(self.cols_to_drop, axis=1)
        return X

# %%
class ExtSourceIntegrity(BaseEstimator):

    def __init__(self, ext_source_cols):
        self.ext_source_cols = ext_source_cols

    def fit(self, X, y=None, **fit_params):
        return self

    def transform(self, X, **transform_params):
        X["EXT_SOURCE_INTEGRITY"] = (X.apply(lambda row: 0
                                             if (row[self.ext_source_cols]
                                                 .isnull().sum() == 3) else
                                             (row[self.ext_source_cols].mean() *
                                              (1 - row[self.ext_source_cols]
                                              .isnull().mean())), axis=1))
        return X

# %%
class OccupationsImputer():
    def __init__(self, occu_gr_cols, occupations=None):
        self.occu_gr_cols = occu_gr_cols
        self.occupations = occupations

    def fit(self, X, y=None, **fit_params):
        self.occupations = (X
                            .groupby(self.occu_gr_cols)["OCCUPATION_TYPE"]
                            .apply(lambda d:
                                   d.value_counts(dropna=False).index[0])
                            .replace(np.nan, "Missed"))
        return self

    def transform(self, X, **transform_params):
        X.reset_index(inplace=True)
        X.set_index(self.occu_gr_cols, inplace=True)
        X.update(self.occupations)
        X.reset_index(inplace=True)
        X.set_index(["SK_ID_CURR"], inplace=True)
        return X

# %%
class DaysEmployedNormalizer():
    def __init__(self, exp_gr_cols, exp_gr_range=None):
        self.exp_gr_cols = exp_gr_cols
        self.exp_gr_range = exp_gr_range

    def fit(self, X, y=None, **fit_params):
        self.exp_gr_range = (X
                             .groupby(self.exp_gr_cols)["DAYS_EMPLOYED"]
                             .agg(["min", "max"]))
        self.exp_gr_range.columns = ["EXP_GR_MAX", "EXP_GR_MIN"]
        return self

    def transform(self, X, **transform_params):
        X = pd.merge(left=X,
                     right=self.exp_gr_range,
                     how="left",
                     left_on=self.exp_gr_cols,
                     right_index=True)
        X["DAYS_EMPLOYED_GR_NORM"] = X.apply(lambda row: 0
                                             if (row["EXP_GR_MAX"] ==
                                                 row["EXP_GR_MIN"]) else
                                             ((row["DAYS_EMPLOYED"] -
                                               row["EXP_GR_MIN"]) /
                                              (row["EXP_GR_MAX"] -
                                               row["EXP_GR_MIN"])), axis=1)
        return X

# %%
class CustomOHEncoder():
    def __init__(self, cols=None):
        self.cols = cols

    def fit(self, X, y=None, **fit_params):
        self.cols = pd.get_dummies(X).columns
        return self

    def transform(self, X, **transform_params):
        df = pd.get_dummies(X)
        for c in self.cols:
            if c not in df:
                df[c] = 0
        return df[self.cols].copy()

# %%
class CustomImputer():
    def __init__(self, cols, strategy="constant", fill_value=None):
        self.strategy = strategy
        self.fill_value = fill_value
        self.cols = cols

    def fit(self, X, y=None, **fit_params):
        if self.strategy == "constant":
            self.fill_value = 0
        elif self.strategy == "mode":
            self.fill_value = X[self.cols].mode()[0]
        return self

    def transform(self, X, **transform_params):
        X.loc[:, self.cols] = X[self.cols].fillna(self.fill_value)
        return X
