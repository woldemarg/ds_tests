## Volodymyr Holomb
#### data scientist applicant / [full CV](https://github.com/woldemarg/ds_tests)



## General analytical strategy and sequence of notebooks:
### 1. Getting stratified sample: [notebook](https://github.com/woldemarg/ds_tests/blob/master/machine_learning/company_3/task_solution/scripts/notebooks/get_sample.ipynb)
### 2. Building the baseline model on a stratified sample: [notebook](https://github.com/woldemarg/ds_tests/blob/master/machine_learning/company_3/task_solution/scripts/notebooks/sample_model.ipynb)
2.1. Dropping unavailing columns based on technical criteria
2.2. Imputing missing values with relevant columns' means or modes from train set
2.3. One-hot encoding categorical features
2.4. Evaluating the model on test data and computing confusion matrix
### 3. Combining all data-wrangling steps into an automated pipeline: [notebook](https://github.com/woldemarg/ds_tests/blob/master/machine_learning/company_3/task_solution/scripts/notebooks/model_pipeline.ipynb)
### 4. Performing hyper-parameters' tuning over pipeline: [notebook](https://github.com/woldemarg/ds_tests/blob/master/machine_learning/company_3/task_solution/scripts/notebooks/pipeline_tuning.ipynb)
4.1. Performing grid search
4.2. Drawing learning curves to estimate model potential
### 5. Predicting with *best*parameters in a pipeline: [notebook](https://github.com/woldemarg/ds_tests/blob/master/machine_learning/company_3/task_solution/scripts/notebooks/pipeline_predict.ipynb)

## Results:
* output file:  [delay_df.csv](https://github.com/woldemarg/ds_tests/raw/master/machine_learning/company_3/task_solution/results/delay_df.csv)
* model desc:   XGBClassifier, 48 predictors, ROC-AUC on CV ~0.91

## Future improvements:
#### 1. Change imputation strategy
#### 2. Remove outliers from general data:
2.1. define clusters
2.2. fit cluster labels to classification model and get the most important features
2.3. define and remove outliers per cluster by most important features
#### 3. Hyper-tuning on general data or broader stratified sample, add params to *grid search*
#### 4. Trying PCA for dimensionality reduction
#### 5. Get columns description and try some sophisticated feature engeenering
