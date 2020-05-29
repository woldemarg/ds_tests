### General analytical strategy and sequence of notebooks:
## 1. Getting stratified sample: [notebook](https://github.com/woldemarg/ds_tests/blob/master/machine_learning/company_3/task_solution/scripts/notebooks/get_sample.ipynb)
## 2. Building the baseline model on a stratified sample
### 2.1. Dropping unavailing columns dased on technical criteria
### 2.2. Imputing missing values with relevant columns' means or modes from train set
### 2.3. One-hot encoding categorical features
### 2.4. Evaluating the model on test data and computing confusion matrix