
The Content of the database
=================================================

Travis CI is used to check that the database conformes in the following way.

## Posteriors `posteriors`

Posteriors are stored as json files as `posteriors/[posterior_name].json`.

All posteriors in the database contain (at minimum):
- `data_name`: Data
- `model_name`: Model code
- `added_by`: Added by (name and github name)
- `added_date`Added date (name and github name)

In addion, the posterior can contain slots on
- `references`: What references should be cited if the data is used. This is BiBTeX slots. The actual references should be found in `references/references.bib`.
- `gold_standard` Path to gold standard with posterior draws
- `keywords`: Keywords for the data (see keywords below)


## Data `data`

All dataset are stored as ziped json-objects in `data/data` and information on the specific data is stored in `data/info`. The raw datasets and reproducible scripts can be found `data/data-raw`.

### `data/data`

1. All data are stored as ziped json files stored as `data/data/[data_name].json.zip`.
2. Matrices are stored as a list of row vectors.

### `data/info`

The data info file contain information on the data used and are stored as   `data/info/[data_name].info.json`.

All data in the database contain (at minimum):
- `data_file`: Path to data json in the database
- `title`: A datset name
- `added_by`: Added by (name and github name)
- `added_date`: Date the file was added (name and github name)

In addion, the posterior can contain slots on
- `references`: What references should be cited if the data is used. This is BiBTeX slots. The actual references should be found in `references/references.bib`.
- `description`: A short description of the data used.
- `urls`: urls to the data to read more.
- `keywords`: Keywords for the data (see keywords below)


### `data/data-raw`

The raw dataset and conversion scripts from raw format to the usable json-files can be found in `data-raw/[data_name]`.

The script should be executable (in R or Python) to reproduce the data-set at the given location and be called `[data_name].r` or `[data_name].py`.

## Models `models`

### `models/info`

The model info file contain information on the model and is stored as   `models/info/[model_name].info.json`.

All data in the database contain (at minimum):
- `model_code`: A named JSON object with one element per framework. For example the "stan" points to a model representation as stan code.
- `title`: A model name
- `added_by`: Added by (name and github name)
- `added_date`: Date the file was added (name and github name)

In addion, the posterior can contain slots on
- `references`: What references should be cited if the model is used. This is BiBTeX elements. The actual references should be included in `references/references.bib`.
- `description`: A short description of the model used.
- `urls`: urls to the model to read more.
- `keywords`: Keywords for the data (see keywords below)

### `models/stan`

Contain models as stan files stored as `models/stan/[model_name].stan`.


## Gold standard `gold_standards`

Contain gold standard draws stored as zipped json as `gold_standards/[posterior_name].json.zip`. See GOLD_STANDARD_CRITERIA.md for details on what is considered to be a gold standard in the posteriordb.

All gold_standard in the database contain (at minimum):
- `posterior_name`: The posterior name.
- `cfg`: Configuration to create a gold standard with the following elements:
  - `inference_method`: How was the draws created (stan_sampling indicates using stan)
  - `inference_method_arguments`: arguments used to create gold_standard, such as `chains`, `iter`, `warmup`, `algorithm` for full reproducibility.
- `posterior_draws`: a named list with all parameter specified in the stan model file of the posterior.
- `added_by`: Added by (name and github name)
- `added_date`: Date the file was added (name and github name)


## References `references`

Contains a bib-tex file with all references in the databases for quickly assembling bibliographies of specific set of posteriors, models or data.


## Schemas `schemas`

JSON-schemas for all elements in the database. Currently not included.
