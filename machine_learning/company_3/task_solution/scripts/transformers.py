# %%
import pandas as pd

# %%
class DropColumnsTransformer():
    def __init__(self,
                 cols_to_drop=None,
                 th_nans=0.35,
                 th_high_cardinality=10):
        self.cols_to_drop = cols_to_drop
        self.th_nans = th_nans
        self.th_high_cardinality = th_high_cardinality

    def transform(self, X, **transform_params):
        df = X.drop(self.cols_to_drop, axis=1).copy()
        return df

    def fit(self, X, y=None, **fit_params):
        cols_nans = X.columns[X.isna().mean() > self.th_nans].tolist()
        ctgs = X.select_dtypes(include="object").columns
        cols_high_cardinality = (ctgs[X[ctgs]
                                      .nunique() > self.th_high_cardinality]
                                 .tolist())
        self.cols_to_drop = list(set(cols_nans) | set(cols_high_cardinality))
        return self

# %%
class CustomImputer():
    def __init__(self, strategy="mean", fill_values=None):
        self.strategy = strategy
        self.fill_values = fill_values

    def transform(self, X, **transform_params):
        df = X.fillna(self.fill_values).copy()
        return df

    def fit(self, X, y=None, **fit_params):
        if self.strategy == "mean":
            self.fill_values = X.mean()
        elif self.strategy == "mode":
            self.fill_values = X.mode()
        return self

# %%
class CustomOHEncoder():
    def __init__(self, cols=None):
        self.cols = cols

    def transform(self, X, **transform_params):
        df = pd.get_dummies(X)
        for c in self.cols:
            if c not in df:
                df[c] = 0
        return df[self.cols].copy()

    def fit(self, X, y=None, **fit_params):
        self.cols = pd.get_dummies(X).columns
        return self

# %%
class CorrelationTransformer():
    def __init__(self,
                 cols_to_drop=None,
                 th_low_variance=0.1,
                 th_corr=0.05):
        self.cols_to_drop = cols_to_drop
        self.th_low_variance = th_low_variance
        self.th_corr = th_corr

    def transform(self, X, **transform_params):
        df = X.drop(self.cols_to_drop, axis=1).copy()
        return df

    def fit(self, X, y=None, **fit_params):
        cols_low_std = (X.columns[(X.std() < self.th_low_variance) &
                                  (X.columns != "gb")]
                        .tolist())
        cols_low_corr = (X.columns[(X.corr().abs()["gb"] < self.th_corr) &
                                   (X.columns != "gb")]
                         .tolist())
        self.cols_to_drop = list(set(cols_low_std) | set(cols_low_corr))
        self.cols_to_drop.append("gb")
        return self
