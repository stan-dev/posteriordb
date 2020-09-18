<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Build
Status](https://travis-ci.org/MansMeg/posteriordb.svg?branch=master)](https://travis-ci.org/MansMeg/posteriordb)
[![codecov](https://codecov.io/gh/MansMeg/posteriordb/branch/master/graph/badge.svg)](https://codecov.io/gh/MansMeg/posteriordb)[![AppVeyor
build
status](https://ci.appveyor.com/api/projects/status/github/MansMeg/posterior_database?branch=master&svg=true)](https://ci.appveyor.com/project/MansMeg/posterior_database)

A Posterior Database (PDB) for Bayesian Inference
=================================================

This repository contains data and models to produce posteriors based on
different probabilistic programming languages (PPL). Currently, the
focus is Stan, but it should be possible to use it with other frameworks
as well.

Purpose of the PDB
------------------

There are many purposes with the PDB

1.  A simple repository to access many models and datasets in a
    structured way from R and Python
2.  Store models and data in a structure that lends itself to testing
    inference algorithms on a large number of posteriors.
3.  An interface that makes it easy for students to access models and
    data for courses in Bayesian data analysis.
4.  Model contents that are framework agnostic (although now Stan is in
    focus), and can be used with many different probabilistic
    programming frameworks.
5.  A structure that simplifies regression testing of probabilistic
    programming frameworks.
6.  Providing reliable reference posteriors for use in inference method
    development.

The long term goal is to move the posterior database to an open RESTful
NoSQL database for easy access.

Content
-------

See
[DATABASE\_CONTENT.md](https://github.com/MansMeg/posteriordb/blob/master/doc/DATABASE_CONTENT.md)
for the details content of the posterior database.

Contributing
------------

We are happy with any help in adding posteriors, data, and models to the
database! See
[CONTRIBUTING.md](https://github.com/MansMeg/posteriordb/blob/master/doc/CONTRIBUTING.md)
for the details on how to contribute.

Quick usage of the posterior database from R
--------------------------------------------

Install the package from GitHub

``` r
remotes::install_github("MansMeg/posteriordb", subdir = "rpackage")
```

Load the R package and load a posterior from the default posteriordb.

``` r
library(posteriordb)
pd <- pdb_default() # Posterior database connection
```

    ## Warning in file(file, "rt", encoding = fileEncoding): cannot open file '/Users/
    ## mansmagnusson/Dropbox/Projekt/posteriordb/.pdb_config.yml': No such file or
    ## directory

    ## Error in file(file, "rt", encoding = fileEncoding) : 
    ##   cannot open the connection

``` r
pn <- posterior_names(pd)
head(pn)
```

    ## [1] "arK-arK"                         "arma-arma11"                    
    ## [3] "bball_drive_event_0-hmm_drive_0" "bball_drive_event_1-hmm_drive_1"
    ## [5] "butterfly-multi_occupancy"       "diamonds-diamonds"

``` r
po <- pdb_posterior("eight_schools-eight_schools_centered", pdb = pd)
po
```

    ## Posterior (eight_schools-eight_schools_centered)
    ## 
    ## Data: eight_schools
    ## The 8 schools dataset of Rubin (1981)
    ## 
    ## Model: eight_schools_centered
    ## A centered hiearchical model for 8 schools
    ## Frameworks: 'stan', 'pymc3'

From the posterior, we can easily access data and models as

``` r
sc <- pdb_stan_code(x = po)
sc
```

    ## data {
    ##   int <lower=0> J; // number of schools
    ##   real y[J]; // estimated treatment
    ##   real<lower=0> sigma[J]; // std of estimated effect
    ## }
    ## parameters {
    ##   real theta[J]; // treatment effect in school j
    ##   real mu; // hyper-parameter of mean
    ##   real<lower=0> tau; // hyper-parameter of sdv
    ## }
    ## model {
    ##   tau ~ cauchy(0, 5); // a non-informative prior
    ##   theta ~ normal(mu, tau);
    ##   y ~ normal(theta, sigma);
    ##   mu ~ normal(0, 5);
    ## }

We can get additional information about the model by using `info()`.

``` r
info(sc)
```

    ## Model: eight_schools_centered
    ## A centered hiearchical model for 8 schools
    ## Frameworks: 'stan', 'pymc3'

To access data for a specific posterior, we can use `pdb_data()`

``` r
dat <- pdb_data(po)
dat
```

    ## $J
    ## [1] 8
    ## 
    ## $y
    ## [1] 28  8 -3  7 -1  1 18 12
    ## 
    ## $sigma
    ## [1] 15 10 16 11  9 11 10 18

Again, we can get additional information about the data by using
`info()`.

``` r
info(dat)
```

    ## Data: eight_schools
    ## The 8 schools dataset of Rubin (1981)

Finally, we can access reference posterior draws for the given
posterior.

``` r
rpd <- reference_posterior_draws(po)
```

The posterior is based on the
[posterior](https://github.com/jgabry/posterior) R package structure and
can easily be summarized and transformed using the `posterior` R
package.

``` r
library(posterior)
```

    ## This is posterior version 0.1.2

``` r
summarize_draws(rpd)
```

    ## # A tibble: 10 x 10
    ##    variable  mean median    sd   mad     q5   q95  rhat ess_bulk ess_tail
    ##    <chr>    <dbl>  <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl>    <dbl>    <dbl>
    ##  1 theta[1]  6.15   5.59  5.62  4.56 -1.68  16.3   1.00   10095.    9732.
    ##  2 theta[2]  4.94   4.77  4.65  4.14 -2.22  12.8   1.00   10049.   10139.
    ##  3 theta[3]  3.91   4.11  5.28  4.48 -4.91  11.8   1.00    9533.    9339.
    ##  4 theta[4]  4.80   4.70  4.77  4.22 -2.67  12.6   1.00   10026.    9666.
    ##  5 theta[5]  3.61   3.82  4.61  4.15 -4.26  10.6   1.00    9922.   10207.
    ##  6 theta[6]  4.05   4.16  4.80  4.32 -3.87  11.5   1.00    9783.   10039.
    ##  7 theta[7]  6.32   5.80  5.00  4.39 -0.855 15.3   1.00   10039.    9690.
    ##  8 theta[8]  4.88   4.79  5.32  4.47 -3.32  13.5   1.00    9605.    9871.
    ##  9 mu        4.41   4.36  3.31  3.30 -0.936  9.83  1.00   10041.    9973.
    ## 10 tau       3.60   2.75  3.20  2.55  0.257  9.73  1.00    9989.    9992.

Using `info()`, we can access more detailed information on the reference
posterior draws.

``` r
info(rpd)
```

    ## Posterior: eight_schools-eight_schools_noncentered
    ## Method: stan_sampling (rstan 2.21.1)
    ## Arguments:
    ##   chains: 10
    ##   iter: 20000
    ##   warmup: 10000
    ##   thin: 10
    ##   seed: 4711
    ##     adapt_delta: 0.95

It is also possible to access only information for models, data, and
draws as follows.

``` r
pdb_model_info(po)
```

    ## Model: eight_schools_centered
    ## A centered hiearchical model for 8 schools
    ## Frameworks: 'stan', 'pymc3'

``` r
pdb_data_info(po)
```

    ## Data: eight_schools
    ## The 8 schools dataset of Rubin (1981)

``` r
pdb_reference_posterior_draws_info(po)
```

    ## Posterior: eight_schools-eight_schools_noncentered
    ## Method: stan_sampling (rstan 2.21.1)
    ## Arguments:
    ##   chains: 10
    ##   iter: 20000
    ##   warmup: 10000
    ##   thin: 10
    ##   seed: 4711
    ##     adapt_delta: 0.95

Using the posterior database from python
----------------------------------------

See [python README](./python/README.md)

Using the posterior database from R (extensive)
-----------------------------------------------

See [R README](./rpackage/README.md)

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
