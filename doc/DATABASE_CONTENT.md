
The Content of the Database
=================================================

Travis CI is used to check that the database conforms in the following way.

## Posteriors `posteriors`

Posteriors are stored as json files as `posteriors/[posterior_name].json`.

All posteriors in the database contain (at minimum):
- `data_name`: Data (name)
- `model_name`: Model (name)
- `added_by`: Added by (name and github name)
- `added_date`: Added date (name and github name)

Also, the posterior can contain slots on
- `references`: What references should be cited if the posterior is used. This is BibTeX slots. The actual references can be found in `references/references.bib`.
- `gold_standard_name`: Gold standard name / posterior name if it extists. Otherwise is `null`.
- `keywords`: Keywords for the data (see keywords below)


## Data `data`

All datasets are stored as zipped JSON-objects in `data/data` and information on the specific data is stored in `data/info`. The raw datasets and reproducible scripts can be found `data/data-raw`.

### `data/data`

1. All data are stored as zipped JSON files stored as `data/data/[data_name].json.zip`.
2. Matrices are stored as a list of row vectors.

### `data/info`

The data info file contains information on the data used and is stored as   `data/info/[data_name].info.json`.

All data in the database contain (at minimum):
- `name`: The dataset name
- `data_file`: Path to data JSON in the database
- `title`: The title for the dataset (used for printing)
- `added_by`: Added by (name and github name)
- `added_date`: Date the file was added (name and github name)

Also, the posterior can contain slots on
- `references`: What references should be cited if the data is used. This is BibTeX slots. The actual references should be found in `references/references.bib`.
- `description`: A short description of the data used.
- `urls`: URLs to the data to read more.
- `keywords`: Keywords for the data (see keywords below)


### `data/data-raw`

The raw dataset and conversion scripts from raw format to the usable JSON-files can be found in `data-raw/[data_name]`.

The script should be executable (in R or Python) to reproduce the data-set at the given location and be called `[data_name].r` or `[data_name].py`.

## Models `models`

### `models/info`

The model info file contains information on the model and is stored as   `models/info/[model_name].info.json`.

All data in the database contain (at minimum):
- `name`: The model name
- `model_code`: A named JSON object with one element per framework. For example, the "stan" points to a model representation as stan code.
- `title`: The title for the model (used for printing)
- `dimensions`: A named list with dimensions per parameter name. Can be used to identify the parameters of the given model if, for example, transformed variables are used. If null, all parameters are relevant and are included in the gold standard.
- `added_by`: Added by (name and github name)
- `added_date`: Date the file was added (name and github name)

Also, the posterior can contain slots on
- `references`: What references should be cited if the model is used. This is BibTeX elements. The actual references should be included in `references/references.bib`.
- `description`: A short description of the model used.
- `urls`: urls to the model to read more.
- `keywords`: Keywords for the model (see keywords below)

### `models/stan`

Contain models as stan files stored as `models/stan/[model_name].stan`.

## Gold standard `gold_standards`

Contain gold standard information are stored as JSON in `gold_standards/info/[posterior_name].info.json`. The actual draws
are stored in `gold_standards/draws/[posterior_name].json.zip`.

See [GOLD_STANDARD_CRITERIA.md](https://github.com/MansMeg/posteriordb/blob/master/docs/GOLD_STANDARD_CRITERIA.md) for details on what is considered to be a gold standard in the posteriordb.

All gold_standard in the database contains (at minimum) the following information:
- `name`: The posterior/gold_standard name.
- `cfg`: Configuration to create a gold standard with the following elements:
  - `inference_method`: How were the draws created (e.g. "stan_sampling" or "analytical")
  - `inference_method_arguments`: arguments used to create gold_standard, such as `chains`, `iter`, `warmup`, `algorithm`, `seed` etc. for full reproducibility.
- `inference_version`: String with version of Rstan/Pystan/stan (e.g. "rstan 2.18.1")
- `added_by`: Added by (name and github name)
- `added_date`: Date the file was added (name and github name)

In addition the gold_standard posterior draws ziped JSON file contain at least the following:
- a named list with all parameters specified in the stan model file of the posterior nested as chains, parameters, draws.


## References `references`

It contains a bib-tex file with all references in the databases for quickly assembling bibliographies of a specific set of posteriors, models or data.


## Schemas `schemas`

JSON-schemas for all elements in the database. Currently not included.


## Keyword

In the database, there are multiple keywords used (and can be added by users). Some relevant keywords of interest:
- `stan_benchmarks`: Models included in the Stan Benchmarks
