# A posterior database

This repository contain data and models to produce posteriors for large-scale Bayesian empirical evaluations of approximate inference algorithms using different probabilistic programing languages.

The database can be used separately or together with the `bayesbench` package.

The database contain
`posteriors`: A folder with the different posteriors as json slots

The content folder contains (this part is not stable and may change)
`content/data`: The data used in the models
`content/data-raw`: Data used to generate the data in the data folder with reproducible code (may be submodule further along).
`content/models`: The models used in different PPF
`content/posterior_gold_standards`: A folder with different posterior draws (may be submodule further along).
`content/schemas`: json schemas used in the database


