# %%
from sklearn.model_selection import StratifiedShuffleSplit
import pandas as pd

# %%
app_train = pd.read_csv("data/raw/application_train.csv.gz",
                        compression="gzip")

# %%
str_split = StratifiedShuffleSplit(n_splits=1,
                                   test_size=0.01 ,
                                   random_state=1234)

for trn_idx, tst_idx in str_split.split(app_train,
                                        app_train[["TARGET",
                                                   "NAME_CONTRACT_TYPE"]]):
    app_samp = app_train.reindex(tst_idx)

# %%
bureau_balance = pd.read_csv("data/raw/bureau_balance.csv.gz",
                             compression="gzip")

bureau = pd.read_csv("data/raw/bureau.csv.gz",
                     compression="gzip")

credit_card_balance = pd.read_csv("data/raw/credit_card_balance.csv.gz",
                                  compression="gzip")

installments_payments = pd.read_csv("data/raw/installments_payments.csv.gz",
                                    compression="gzip")

POS_CASH_balance = pd.read_csv("data/raw/POS_CASH_balance.csv.gz",
                               compression="gzip")

previous_application = pd.read_csv("data/raw/previous_application.csv.gz",
                                   compression="gzip")

# %%
bur_samp = (bureau
            .loc[bureau["SK_ID_CURR"]
                 .isin(app_samp["SK_ID_CURR"]), :])

bur_bal_samp = (bureau_balance
                .loc[bureau_balance["SK_ID_BUREAU"]
                     .isin(bur_samp["SK_ID_BUREAU"]), :])

# %%
prev_app_samp = (previous_application
                 .loc[previous_application["SK_ID_CURR"]
                      .isin(app_samp["SK_ID_CURR"]), :])

# %%
ps_bal_samp = (POS_CASH_balance
               .loc[(POS_CASH_balance["SK_ID_CURR"]
                     .isin(prev_app_samp["SK_ID_CURR"])) |
                    (POS_CASH_balance["SK_ID_PREV"]
                     .isin(prev_app_samp["SK_ID_PREV"])), :])

# %%
in_pay_samp = (installments_payments
               .loc[(installments_payments["SK_ID_CURR"]
                     .isin(prev_app_samp["SK_ID_CURR"])) |
                    (installments_payments["SK_ID_PREV"]
                     .isin(prev_app_samp["SK_ID_PREV"])), :])

# %%
cc_bal_samp = (credit_card_balance
               .loc[(credit_card_balance["SK_ID_CURR"]
                     .isin(prev_app_samp["SK_ID_CURR"])) |
                    (credit_card_balance["SK_ID_PREV"]
                     .isin(prev_app_samp["SK_ID_PREV"])), :])

# %%
my_dict = {"app_samp": app_samp,
           "bur_samp": bur_samp,
           "bur_bal_samp": bur_bal_samp,
           "prev_app_samp": prev_app_samp,
           "ps_bal_sampp": ps_bal_samp,
           "in_pay_samp": in_pay_samp,
           "cc_bal_samp": cc_bal_samp}


def to_csv(d):
    for key, value in d.items():
        value.to_csv("data/samples/" + key + ".csv.gz",
                     compression="gzip")


to_csv(my_dict)
