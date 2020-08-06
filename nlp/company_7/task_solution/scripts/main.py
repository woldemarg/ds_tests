import json
import re
import spacy

import pandas as pd
import numpy as np

from spacy.pipeline import EntityRuler
from nlp.company_7.task_solution.scripts.keywords import keywords

#%%
df = pd.read_csv("nlp/company_7/task_solution/data/data.csv.gz",
                 index_col="id")

#%%
df.head()

#%%
nlp_main = spacy.load("en_core_web_lg", disable=["tagger", "parser"])
nlp_helper = spacy.load("en_core_web_sm", disable=["parser", "ner"])

#%%
strings = []

for jsn in df["json"]:
    d = json.loads(jsn)
    s = "".join(v.strip()
                .replace("\n", " ")
                .replace("\t", " ")
                for v in d.values())
    strings.append(s)

s_strings = pd.Series(strings, index=df.index)

#%%
def is_all_propn(st):
    propns = []
    for w in st.split(" "):
        w_doc = nlp_helper(w)
        for t in w_doc:
            propns.append(t.pos_)
    return all((el == "PROPN" for el in propns))


def correct_person_entities(nlp_doc):
    new_ents = []
    for ent in nlp_doc.ents:
        if ent.label_ == "PERSON":
            if (re.search(r"^([A-Z][\w]+\s[A-Z]?\.?\s?[A-Z][\w]+)$",
                          ent.text) and is_all_propn(ent.text)):
                new_ents.append(ent)
        else:
            new_ents.append(ent)
    nlp_doc.ents = new_ents
    return nlp_doc

#%%
patterns = []

for k, v in keywords().items():
    for s in v:
        new = {}
        new["label"] = k
        new["pattern"] = [{"LOWER": w.lower()} for w in s.split(" ")]
        patterns.append(new)

#%%
ruler = EntityRuler(nlp_main)
ruler.add_patterns(patterns)

#%%
nlp_main.add_pipe(ruler, before="ner")
nlp_main.add_pipe(correct_person_entities, after="ner")

#%%
data_ls = []

for i, el in s_strings.items():
    doc = nlp_main(el)
    if (any([n.label_ == "academic_title" for n in doc.ents]) and
            any([n.label_ == "PERSON" for n in doc.ents])):

        names = [n.text for n in doc.ents if n.label_ == "PERSON"]
        nx = np.asarray([n.start_char for n
                         in doc.ents if n.label_ == "PERSON"])
        titles = [n.text for n
                  in doc.ents if n.label_ == "academic_title"]
        ty = np.asarray([n.start_char for n
                         in doc.ents if n.label_ == "academic_title"])

        diff_arr = np.abs(ty - nx[:, np.newaxis])
        min_vals = np.where(diff_arr == np.amin(diff_arr))
        indicies = list(zip(min_vals[0], min_vals[1]))
        data_ls.append((i, names[indicies[0][0]], titles[indicies[0][1]]))

#%%
data_df = pd.DataFrame(data_ls, columns=["id", "name", "academic_title"])
data_df.set_index("id", inplace=True)


def remove_middle_name(nn):
    n = nn.split(" ")
    return " ".join((n[0], n[-1]))


data_df.loc[:, "name"] = data_df["name"].map(remove_middle_name)
data_df[["first_name", "last_name"]] = data_df["name"].str.split(expand=True)

data_df.loc[:, "academic_title"] = data_df["academic_title"].str.title()

#%%
df.update(data_df)
df.head()

#%%
print(1 - df["first_name"].isna().mean())

#%%
df.reset_index(inplace=True)
df.to_csv("nlp/company_7/task_solution/results/data_new.csv.gz")
