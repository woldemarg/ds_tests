import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from sklearn.preprocessing import OneHotEncoder
from sklearn.preprocessing import StandardScaler

from sklearn.cluster import KMeans

from sklearn.metrics import silhouette_score
from sklearn.metrics import calinski_harabasz_score

from sklearn.decomposition import PCA

from sklearn.ensemble import RandomForestClassifier

# %%
url = "https://raw.githubusercontent.com/woldemarg/nix_solutions_test/master/task_3/data/Data%20for%20the%20Churn%20task%20_%20BDA%20homework.csv"
data = pd.read_csv(url)

data.head()

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
                                       "Yes": 1,
                                       "No": 0,
                                       "No phone service": 0,
                                       "No internet service": 0}))

data_mod.loc[:, "InternetService"] = (data_mod.InternetService
                                      .replace({
                                          "No": 0,
                                          "DSL": 1,
                                          "Fiber optic": 2}))

# %%
cat_cols_left = [col for col in data_mod
                 if data_mod[col].dtype == "object"]

OH_encoder = OneHotEncoder(handle_unknown="error",
                           drop="first", sparse=False)

OH_cols = pd.DataFrame(OH_encoder.fit_transform(data_mod[cat_cols_left]))

OH_cols_names = OH_encoder.get_feature_names(cat_cols_left)
OH_cols.columns = OH_cols_names

data_num = pd.concat([data_mod.drop(cat_cols_left, axis=1), OH_cols],
                     axis=1)

data_num.head()

# %%
(data_num[(data_num.PhoneService == 0) &
         (data_num.InternetService != 0)]["MonthlyCharges"]
 .agg(["min", "mean", "max"]))

# %%
(data[(data.PhoneService == "No") &
         (data.InternetService != "No")]
 .groupby("PaymentMethod")["MonthlyCharges"]
 .agg(["min", "mean", "max", "count"]))

# %%
(data_num
 .groupby("Churn")["MonthlyCharges"]
 .sum() / data_num["MonthlyCharges"].sum() * 100)

# %%
(data[data.Churn == "Yes"]
 .groupby("Contract")["Churn"]
 .count())

# %%
(data
 .assign(tenure_bins=pd.cut(data["tenure"],
                            [0, 10, 30, 50, 72],
                            include_lowest=True,
                            precision=0))
 .groupby("tenure_bins")["MonthlyCharges"]
 .sum() / data["MonthlyCharges"].sum() *100)

# %%
y = data_num.Churn
X = data_num.drop(["Churn"], axis=1)

# %%
scaler = StandardScaler()

X_scaled = pd.DataFrame(scaler.fit_transform(X))
X_scaled.columns = X.columns

# %%
sl_scores = []
ch_scores = []
k_means_res = {}

num_clusters = range(2, 11)


for k in num_clusters:
    k_means = KMeans(n_clusters=k).fit(X_scaled)

    sl_scores.append(silhouette_score(X_scaled,
                                      k_means.labels_,
                                      metric='euclidean'))

    ch_scores.append(calinski_harabasz_score(X_scaled,
                                             k_means.labels_))

    k_means_res.update({k: k_means.__dict__})

# %%
fig, ax1 = plt.subplots()

color = "tab:red"
ax1.set_xlabel("num of clusters")
ax1.set_ylabel("CH scores", color=color)
ax1.plot(num_clusters, ch_scores, color=color)
ax1.tick_params(axis='y', labelcolor=color)
ax1.axvline(x=4, linestyle="--", color="tab:grey", linewidth=0.75)
ax2 = ax1.twinx()

color = 'tab:blue'
ax2.set_ylabel("silhouette scores", color=color)
ax2.plot(num_clusters, sl_scores, color=color)
ax2.tick_params(axis='y', labelcolor=color)

fig.tight_layout()
plt.title("Potential number of clusters")
plt.show()

# %%
k_best = 4

pca = PCA(n_components=2)

principal_components = pca.fit_transform(X_scaled)

principal_df = pd.DataFrame(data=principal_components,
                            columns=["PC_1", "PC_2"])

data_pca = pd.concat([principal_df,
                      pd.Series(k_means_res[k_best]["labels_"],
                                name="cluster_labels"),
                      y], axis=1)


clusters = np.unique(data_pca.cluster_labels)
colors = ["tab:blue", "tab:orange", "tab:green", "tab:red"]
colors_dict = dict(zip(clusters, colors))
data_pca["cluster_colors"] = (data_pca.cluster_labels
                              .apply(lambda x: colors_dict[x]))


data_pca.plot.scatter(x="PC_1",
                      y="PC_2",
                      c=data_pca.cluster_colors,
                      s=3,
                      alpha=0.5)

# %%
data_clusters = pd.concat([X, data_pca.cluster_labels], axis=1)

internet = (data_clusters
            .groupby(["cluster_labels", "InternetService"])
            .agg({"InternetService": "count"})
            .unstack(level=-1, fill_value=0))

internet

# %%
i_services = data_clusters.iloc[:, [7, 8, 9, 10, 11, 12, 21]]

i_services_share = (i_services
                    .groupby("cluster_labels")
                    .apply(lambda df: df.sum() / df.count() * 100)
                    .drop("cluster_labels", axis=1))


def draw_heatmap(d, x_ticks, y_ticks, title, x_label=None, y_label=None):
    fig_hm, ax = plt.subplots()
    hm = plt.pcolor(d)
    ax.set_xticks(np.arange(d.shape[1]) + 0.5)
    ax.set_yticks(np.arange(d.shape[0]) + 0.5)
    ax.set_xticklabels(x_ticks)
    ax.set_yticklabels(y_ticks)
    ax.set_xlabel(x_label)
    ax.set_ylabel(y_label)
    plt.setp(ax.get_xticklabels(),
             rotation=45,
             ha="right",
             rotation_mode="anchor")
    for i in range(d.shape[0]):
        for j in range(d.shape[1]):
            plt.text(j + 0.5, i + 0.5, '%.1f' % d.iloc[i, j],
                     horizontalalignment='center',
                     verticalalignment='center')
    plt.colorbar(hm)
    fig_hm.tight_layout()
    ax.set_title(title)
    plt.show()


draw_heatmap(i_services_share,
             i_services_share.columns,
             range(4),
             "% of users by received Internet services per cluster")

# %%
mon_income = (data_clusters
              .groupby("cluster_labels")["MonthlyCharges"].sum()
              .apply(lambda x:
                     x / data_clusters["MonthlyCharges"].sum() * 100))
mon_income

# %%
mon_income_avg = (data_clusters
                  .groupby("cluster_labels")["MonthlyCharges"].mean())

mon_income_avg

# %%
churn_per_cluster = (data_pca
                     .groupby(["cluster_labels", "Churn"])
                     .agg({"Churn": "count"}))

churn_per_cluster["ratio"] = (churn_per_cluster
                              .groupby(level=0)
                              .apply(lambda x:
                                     100 * x / x.sum()))

# %%
rf_mod = RandomForestClassifier(class_weight="balanced_subsample")

rf_mod_churn = rf_mod.fit(X, y)

f_imp_churn = pd.Series(rf_mod_churn.feature_importances_,
                        index=X.columns)


plt.figure()
f_imp_churn.nlargest(5).plot(kind="barh")
plt.show()

# %%
rf_mod_clusters = rf_mod.fit(X, data_pca["cluster_labels"])

f_imp_clusters = pd.Series(rf_mod_clusters.feature_importances_,
                           index=X.columns)


plt.figure()
f_imp_clusters.nlargest(5).plot(kind="barh")
plt.show()

# %%
data_clusters["MonthlyCharges_desc"] = pd.qcut(data_clusters.MonthlyCharges,
                                              q=5,
                                              precision=0)

data_clusters["tenure_desc"] = pd.qcut(data_clusters.tenure,
                                      q=5,
                                      precision=0)

data_clusters_churn = pd.concat([data_clusters, y], axis=1)

task_cluster = (data_clusters_churn
                .loc[data_clusters.cluster_labels == churn_per_cluster
                     .unstack(level=1)["ratio"][1]
                     .idxmax(), :])

cluster_grouped = (task_cluster
                   .groupby(["MonthlyCharges_desc",
                               "tenure_desc",
                               "Churn"])
                    .agg({"Churn": "count"})
                    .unstack(level=2))


def get_churn_ratio(row):
    row["ratio"] = row[1] / row.sum() * 100 if row[1] != 0 else 0
    return row


cluster_churn_ratio = (cluster_grouped
                       .apply(get_churn_ratio, axis=1)["ratio"]
                       .unstack(level=1))

draw_heatmap(cluster_churn_ratio,
             cluster_churn_ratio.columns,
             cluster_churn_ratio.index,
             "Churn rate in a given cluster per tenure and charge",
             "tenure range (months)",
             "monthly charge range (USD)")
