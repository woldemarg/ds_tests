# %%
from flask import Flask, jsonify, request, render_template

import pickle
import pandas as pd

from helper_funcs import hours_of_daylight, assign_columns, long_holidays

# %%
app = Flask(__name__)
app.secret_key = "pass"

model_pipe = pickle.load(open("model_pipe.pkl", "rb"))

# %%
@app.route("/")
def docs():
    """Describe the model API inputs and outputs for users."""
    return render_template("docs.html")

# %%
@app.route("/api", methods=["GET"])
def api():
    """Handle request and output model score in json format."""
    if not request.json:
        return jsonify({"error": "no request received"})

    X = parse_args(request.json)

    response = (X
                .assign(predictions=model_pipe.predict(X).round(0))
                .set_index(["company_name", X.index.strftime("%Y-%m-%d")])
                .groupby(level=0)
                .apply(lambda df: df.xs(df.name).to_dict())
                .to_dict())

    return jsonify(response)

# %%
def parse_args(request_dict):
    """Parse model features from incoming requests formatted in JSON."""
    idx = (pd.date_range(request_dict["from"],
                         request_dict["to"])
           .repeat(2))

    ls = ["jalan", "rakuten"] * int(len(idx) / 2)

    X = pd.DataFrame(data=ls,
                     index=idx,
                     columns=["company_name"])
    return X

# %%
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
