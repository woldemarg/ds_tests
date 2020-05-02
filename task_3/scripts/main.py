import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from sklearn.preprocessing import OneHotEncoder
from sklearn.preprocessing import StandardScaler

from sklearn.cluster import KMeans

from sklearn.metrics import silhouette_score
from sklearn.metrics import calinski_harabasz_score

from sklearn.decomposition import PCA

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

data_num = pd.concat([data_mod.drop(cat_cols_left, axis=1), OH_cols],
                     axis=1)

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
                                      metric = 'euclidean'))

    ch_scores.append(calinski_harabasz_score(X_scaled,
                                             k_means.labels_))

    k_means_res.update({k: k_means.__dict__})

fig, ax1 = plt.subplots()

color = "tab:red"
ax1.set_xlabel("num of clusters")
ax1.set_ylabel("CH score", color=color)
ax1.plot(num_clusters, ch_scores, color=color)
ax1.tick_params(axis='y', labelcolor=color)
ax1.axvline(x=4, linestyle="--", color="tab:grey", linewidth=0.75)
ax2 = ax1.twinx()

color = 'tab:blue'
ax2.set_ylabel("silhouette score", color=color)
ax2.plot(num_clusters, sl_scores, color=color)
ax2.tick_params(axis='y', labelcolor=color)

fig.tight_layout()
plt.show()

k_best = 4

# %%
pca = PCA(n_components=2)

principal_components = pca.fit_transform(X_scaled)

principal_df = pd.DataFrame(data = principalComponents,
                            columns = ["PC_1", "PC_2"])

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
churn_per_cluster = (data_pca
                     .groupby(["cluster_labels", "Churn"])
                     .agg({"Churn": "count"}))

cluster_size = data_pca.groupby("cluster_labels").count()

churn_ratio = (churn_per_cluster
               .div(cluster_size, level="cluster_labels")
               .loc[:, "Churn"]
               .rename("ratio")
               .reset_index()
               .query("Churn == 1"))

