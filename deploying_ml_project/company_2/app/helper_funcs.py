# %%
from datetime import datetime

import numpy as np
import pandas as pd

# %%
holidays = pd.read_csv("holidays_Japan.csv",
                       parse_dates=[0],
                       index_col=0)

def is_long_holidays(row):
    if (row.Japan_prev == 0 and
            row.Japan == 1 and
            row.Japan_next == 1):
        return 1
    if (row.name.dayofweek == "4" and
            row.Japan == 1):
        return 1
    if (row.name.dayofweek == "5" and
            row.Japan_next_next == 1):
        return 1
    return 0


holidays_mod = (holidays
                .assign(Japan_prev=holidays.Japan.shift(1))
                .assign(Japan_next=holidays.Japan.shift(-1))
                .assign(Japan_next_next=holidays.Japan.shift(-2)))


long_holidays = holidays_mod.apply(is_long_holidays, axis=1)

# %%
def hours_of_daylight(date, axis=23.44, latitude=42.49):
    """Compute the hours of daylight for the given date"""
    diff = date - datetime(2000, 12, 21)
    day = diff.total_seconds() / 24 / 3600
    day %= 365.25
    m = (1 - np.tan(np.radians(latitude)) *
         np.tan(np.radians(axis) *
                np.cos(day * np.pi / 182.625)))
    m = max(0, min(m, 2))
    return 24 * np.degrees(np.arccos(1 - m)) / 180

# %%
def assign_columns(x_in):
    x_out = (x_in
             .assign(daylight=x_in.index.map(hours_of_daylight))
             .assign(day_of_week=x_in.index.dayofweek)
             .assign(is_long_holidays=long_holidays))
    return x_out
