# %%
import re
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
        X.loc[:, "APART_DESC_INTEGRITY"] = (1 - X[self.apartment_cols]
                                            .isnull().mean(axis=1))
        X.loc[:, "GOODS_RATIO"] = (X.apply(lambda row:
                                           0 if np.isnan(row["AMT_GOODS_PRICE"])
                                           else (row["AMT_GOODS_PRICE"] /
                                                 row["AMT_CREDIT"]), axis=1))
        X = X.eval("ANNUITY_RATIO = AMT_ANNUITY / AMT_INCOME_TOTAL")
        X.drop(self.cols_to_drop, axis=1, inplace=True)
        return X.copy()

# %%
class ExtSourceIntegrity(BaseEstimator):

    def __init__(self, ext_source_cols):
        self.ext_source_cols = ext_source_cols


    def fit(self, X, y=None, **fit_params):
        return self


    def transform(self, X, **transform_params):
        X.loc[:, "EXT_SOURCE_INTEGRITY"] = (X.apply(lambda row: 0
                                                    if (row[self.ext_source_cols]
                                                        .isnull().sum() == 3)
                                                    else (row[self.ext_source_cols]
                                                          .mean() *
                                                          (1 - row[self.ext_source_cols]
                                                      .isnull().mean())), axis=1))
        return X.copy()

# %%
class OccupationsImputer(BaseEstimator):

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
        return X.copy()

# %%
class DaysEmployedNormalizer(BaseEstimator):

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
        X.loc[:, "DAYS_EMPLOYED_GR_NORM"] = X.apply(lambda row: 0
                                                    if (row["EXP_GR_MAX"] ==
                                                        row["EXP_GR_MIN"]) else
                                                    ((row["DAYS_EMPLOYED"] -
                                                      row["EXP_GR_MIN"]) /
                                                     (row["EXP_GR_MAX"] -
                                                      row["EXP_GR_MIN"])), axis=1)
        X = X.eval("DAYS_EMPLOYED = DAYS_EMPLOYED * DAYS_EMPLOYED_GR_NORM")
        return X.copy()

# %%
class CustomOHEncoder(BaseEstimator):

    def __init__(self, cols=None):
        self.cols = cols


    def fit(self, X, y=None, **fit_params):
        self.cols = [re.compile(r"\[|\]|<", re.IGNORECASE).sub("_", col)
                     if any(x in str(col) for x in set(("[", "]", "<")))
                     else col for col in pd.get_dummies(X).columns.values]
        return self


    def transform(self, X, **transform_params):
        df = pd.get_dummies(X)
        df.columns = [re.compile(r"\[|\]|<", re.IGNORECASE).sub("_", col)
                      if any(x in str(col) for x in set(("[", "]", "<")))
                      else col for col in df.columns.values]
        for c in self.cols:
            if c not in df:
                df[c] = 0
        return df[self.cols].copy()

# %%
class CustomImputer(BaseEstimator):

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
        return X.copy()

# %%
class CustomQuantileDiscretizer(BaseEstimator):

    def __init__(self, cols, col_bins=None, q=50):
        self.cols = cols
        self.col_bins = col_bins
        self.q = q


    def fit(self, X, y=None, **fit_params):
        self.col_bins = {}
        for col in self.cols:
            bins = pd.qcut(x=X[col],
                           q=self.q,
                           duplicates="drop",
                           precision=0,
                           retbins=True)[1]
            self.col_bins.update({col: bins})
        return self


    def transform(self, X, **transform_params):
        for col in self.cols:
            X.loc[:, col] = pd.cut(X[col], self.col_bins[col])
        return X.copy()

# %%
class ZscoreQuantileDiscretizer(BaseEstimator):

    def __init__(self, bins=None, q=7):
        self.bins = bins
        self.q = q


    def fit(self, X, y=None, **fit_params):
        self.bins = pd.qcut(x=X["zscore"],
                            q=self.q,
                            duplicates="drop",
                            precision=0,
                            retbins=True)[1]
        return self


    def transform(self, X, **transform_params):
        X["zscore"] = [min(self.bins) if v < min(self.bins)
                       else max(self.bins) if v > max(self.bins)
                       else v for v in X["zscore"]]

        X["zscore_disc"] = pd.cut(X["zscore"],
                                  self.bins,
                                  include_lowest=True)
        return X.copy()

# %%
class DaysEmployedZscore(BaseEstimator):

    def __init__(self, exp_gr_cols, mean_std=None):
        self.exp_gr_cols = exp_gr_cols
        self.mean_std = mean_std


    def fit(self, X, y=None, **fit_params):
        self.mean_std = (X
                         .groupby(self.exp_gr_cols)["DAYS_EMPLOYED"]
                         .agg(["mean", "std"]))
        return self


    def transform(self, X, **transform_params):
        X = (X
             .merge(self.mean_std,
                    how="left",
                    left_on=self.exp_gr_cols,
                    right_index=True))
        X = X.eval("zscore = (DAYS_EMPLOYED - mean) / std")
        X["zscore"].fillna(0, inplace=True)
        return X.copy()
