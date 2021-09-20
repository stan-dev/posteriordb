<!-- README.md is generated from README.Rmd. Please edit that file -->

[![posteriordb
Content](https://github.com/stan-dev/posteriordb/actions/workflows/posteriordb_content.yml/badge.svg)](https://github.com/stan-dev/posteriordb/actions/workflows/posteriordb_content.yml)
[![R-CMD-check](https://github.com/stan-dev/posteriordb-r/actions/workflows/check-release.yaml/badge.svg)](https://github.com/stan-dev/posteriordb-r/actions/workflows/check-release.yaml)
[![Codecov test
coverage](https://codecov.io/gh/stan-dev/posteriordb-r/branch/main/graph/badge.svg)](https://codecov.io/gh/stan-dev/posteriordb-r?branch=main)
[![Python](https://github.com/stan-dev/posteriordb-python/actions/workflows/push.yml/badge.svg)](https://github.com/stan-dev/posteriordb-python/actions/workflows/push.yml)

`posteriordb`: a database of Bayesian posterior inference
=========================================================

What is `posteriordb`?
----------------------

`posteriordb` is a set of posteriors, i.e. Bayesian statistical models
and data sets, reference implementations in probabilistic programming
languages, and reference posterior inferences in the form of posterior
samples.

Why use `posteriordb`?
----------------------

`posteriordb` is designed to test inference algorithms across a wide
range of models and data sets. Applications include testing for
accuracy, speed, and scalability. `posteriordb` can be used to test new
algorithms being developed or deployed as part of continuous integration
for ongoing regression testing algorithms in probabilistic programming
frameworks.

`posteriordb` also makes it easy for students and instructors to access
various pedagogical and real-world examples with precise model
definitions, well-curated data sets, and reference posteriors.

`posteriordb` is framework agnostic and easily accessible from R and
Python.

For more details regarding the use cases of `posteriordb`, see
[doc/use\_cases.md](https://github.com/stan-dev/posteriordb/blob/master/doc/use_cases.md).

Content
-------

See
[DATABASE\_CONTENT.md](https://github.com/stan-dev/posteriordb/blob/master/doc/DATABASE_CONTENT.md)
for the details content of the posterior database.

Contributing
------------

We are happy with any help in adding posteriors, data, and models to the
database! See
[CONTRIBUTING.md](https://github.com/stan-dev/posteriordb/blob/master/doc/CONTRIBUTING.md)
for the details on how to contribute.

Using `posteriordb`
-------------------

To simplify the use of `posteriordb`, there are convenience functions
both in Python and in R. To use R, see the
[posteriordb-r](https://github.com/stan-dev/posteriordb-r) repository,
and to use Python, see the
[posteriordb-python](https://github.com/stan-dev/posteriordb-python)
repository.

Citing `posteriordb`
--------------------

Developing and maintaining open-source software is an important yet
often underappreciated contribution to scientific progress. Thus, please
make sure to cite it appropriately so that developers get credit for
their work. Information on how to cite `posteriordb` can be found in the
[CITATION.cff](https://github.com/stan-dev/posteriordb/blob/master/CITATION.cff)
file. Use the “cite this repository” button under “About” to get a
simple BibTeX or APA snippet.

As `posteriordb` rely heavily on Stan, so please consider also to cite
Stan:

Carpenter B., Gelman A., Hoffman M. D., Lee D., Goodrich B., Betancourt
M., Brubaker M., Guo J., Li P., and Riddell A. (2017). Stan: A
probabilistic programming language. Journal of Statistical Software.
76(1). 10.18637/jss.v076.i01

Design choices (so far)
-----------------------

The main focus of the database is simplicity, both in understanding and
in use.

The following are the current design choices in designing the posterior
database.

1.  Priors are hardcoded in model files as changing the prior changes
    the posterior. Create a new model to test different priors.
2.  Data transformations are stored as different datasets. Create new
    data to test different data transformations, subsets, and variable
    settings. This design choice makes the database larger/less memory
    efficient but simplifies the analysis of individual posteriors.
3.  Models and data has (model/data).info.json files with model and data
    specific information.
4.  Templates for different JSONs can be found in content/templates and
    schemas in schemas (Note: these don’t exist right now and will be
    added later)
5.  Prefix ‘syn\_’ stands for synthetic data where the generative
    process is known and found in content/data-raw.
6.  All data preprocessing is included in content/data-raw.
7.  Specific information for different PPL representations of models is
    included in the PPL syntax files as comments, not in the
    model.info.json files.

Versioning of models
--------------------

We might update models included in posteriordb over time. However, the
models will only have the same name in posteriordb if the log density is
the same (up to a normalizing constant). Otherwise, we will include a
new model in the database.
