# A Posterior Database

This repository contain data and models to produce posteriors for large-scale Bayesian empirical evaluations of approximate inference algorithms using different probabilistic programing languages.

## Design choices (so far)

The following are the current design choices in designing the posterior database.

1. Priors are hardcoded in model
   Create a new model to test different priors
2. Data transformations are stored as different datasets
   Create a new data to test different data transformations, subsets and variable settings
3. Models and data has [model/data].info.json model and data specific information.
4. Templates for different jsons can be found in content/templates and schemas in schemas
5. Prefix 'syn_' stands for synthetic data where the generative process is known and can be found in content/data-raw
5. Prefix '[dataname]_' indicates real dataset
6. All data preprocessing be included in data-raw

## R package

The included database contain convinience functions to access data, stan code and information for individual posteriors.




## Content

The database contain

1. `posteriors`: A folder with the different posteriors as json slots pointing to data and models
2. The content folder contains (this part is not stable and may change)
  a. `content/data`: The data used in the models
  b. `content/data-raw`: Data used to generate the data in the data folder with reproducible code (may be git submodule further along).
  c. `content/models`: The models used in different PPF
  d. `content/posterior_gold_standards`: A folder with different posterior draws (may be git submodule further along).
  e. `content/schemas`: json schemas used in the database
  e. `content/templates`: json schemas used in the database  




