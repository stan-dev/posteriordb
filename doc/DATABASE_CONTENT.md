
The Content of the Posterior Database
=================================================

Github Actions is used to check that the database conforms to the following structure.

## Posteriors `posteriors`

Posteriors are stored as json files as `posteriors/[posterior_name].json`.

All posteriors in the database contain (at minimum):
- `data_name`: Data (name)
- `model_name`: Model (name)
- `added_by`: Name of the person that added the posterior
- `added_date`: Date of the person that added the posterior

Also, the posterior can contain slots on
- `references`: What references should be cited if the posterior is used. These are using BibTeX short names. You can find the actual references in `references/references.bib`.
- `reference_posterior_name`: Reference posterior name if it exists/has been computed. Otherwise is `null`.
- `dimension`: Dimensions of different parameter names. The sum is the total dimension of the posterior. Hence the dimension of the Dirichlet vector of length K is K - 1.
- `keywords`: Keywords for the data (see keywords below)


## Data `data`
All datasets are stored as zipped JSON objects in `data/data`, and information on the specific data is stored in `data/info`. The raw datasets and reproducible scripts can be found `data/data-raw`.

### `data/data`

1. All data are stored as zipped JSON files as `data/data/[data_name].json.zip`.
2. Matrices are stored as a list of row vectors.

### `data/info`

The data info file contains information on the data used and is stored as   `data/info/[data_name].info.json`.

All data in the database contain (at minimum):
- `name`: The dataset name
- `data_file`: Path to data JSON in the database
- `title`: The title for the dataset (used for printing)
- `added_by`: Name of the person who added the dataset.
- `added_date`: Date when the dataset was added.

Also, the posterior can contain slots on
- `references`: What references should be cited if the dataset is used. These are using BibTeX short names. You can find the actual references in `references/references.bib`.
- `description`: A short description of the data used.
- `urls`: URLs to the data with more information.
- `keywords`: Keywords for the data (see keywords below)


### `data/data-raw`

We can find the raw dataset and conversion scripts from raw format to the usable JSON files in `data-raw/[data_name]`.

The script should be executable (in R or Python) to reproduce the dataset at the given location and be called `[data_name].r` or `[data_name].py`.

## Models `models`

### `models/info`

The model info file contains information on the model and is stored as `models/info/[model_name].info.json`.

All models in the database contain (at minimum):
- `name`: The model name
- `model_code`: A named JSON object with one element per framework. For example, the "stan" points to a model representation as stan code.
- `title`: The title for the model (used for printing)
- `added_by`: Name of the person who added the dataset.
- `added_date`: Date when the dataset was added.

Also, the models can contain slots on
- `references`: What references should be cited if the model is used. These are using BibTeX short names. You can find the actual references in `references/references.bib`.
- `description`: A short description of the model used.
- `urls`: urls to the model to read more.
- `keywords`: Keywords for the model (see keywords below)

### `models/stan`

Contain models as stan files stored as `models/stan/[model_name].stan`.

## Posterior reference draws `reference_draws`

Contain reference draws information are stored as JSON in `reference_posteriors/draws/info/[posterior_name].info.json`. The actual draws are stored in `reference_posteriors/draws/[posterior_name].json.zip`.

See [REFERENCE_POSTERIOR_DEFINITION.md](https://github.com/stan-dev/posteriordb/blob/master/doc/REFERENCE_POSTERIOR_DEFINITION.md) for details on what is considered to be reference posterior draws in the posteriordb.

All reference draws in the database contains (at minimum) the following information:
- `name`: The reference_posterior name.
 "comments", "added_by", "added_date", "versions"
- `inference`:
  - `method`: How were the draws created (e.g. "stan_sampling" or "analytical")
  - `method_arguments`: arguments used to create reference_posterior, such as `chains`, `iter`, `warmup`, `algorithm`, `seed` etc., for full reproducibility.
- `diagnostics`: Stored diagnostic values of the reference posterior
- `checks_made`: Checks made on the reference posterior to asses it complies with the reference posterior definition. See [REFERENCE_POSTERIOR_DEFINITION.md](https://github.com/stan-dev/posteriordb/blob/master/doc/REFERENCE_POSTERIOR_DEFINITION.md).
- `comments`: Additional comments on the
- `added_by`: Added by (name)
- `added_date`: Date the file was added
- `versions`:

## References `references`

It contains a bib-tex file with all references in the databases for quickly assembling bibliographies of a specific set of posteriors, models or data.


## Schemas `schemas`

JSON-schemas for all elements in the database. Currently not included.


## Keyword

In the database, multiple keywords are used (and can be added by users). Some relevant keywords of interest:
- `stan_benchmarks`: Models included in the Stan Benchmarks
