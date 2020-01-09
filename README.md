<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build
Status](https://travis-ci.org/MansMeg/posteriordb.svg?branch=master)](https://travis-ci.org/MansMeg/posteriordb)
[![codecov](https://codecov.io/gh/MansMeg/posteriordb/branch/master/graph/badge.svg)](https://codecov.io/gh/MansMeg/posteriordb)

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
2.  Store models and data in a structure that lends itself for testing
    inference algorithms on a large number of posteriors.
3.  A structure that makes it easy for students to access models and
    data for courses in Bayesian data analysis.
4.  A structure that is framework agnostic (although now Stan is in
    focus) and can be used with many different probabilistic programming
    frameworks.
5.  A structure that simplifies regression testing of probabilistic
    programming frameworks.
6.  Providing reliable gold standards for use in inference method
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

We are happy with any help in adding posteriors, data and models to the
database! See
[CONTRIBUTING.md](https://github.com/MansMeg/posteriordb/blob/master/doc/CONTRIBUTING.md)
for the details on how to contribute.

Quick usage of the posterior database from R
--------------------------------------------

Install the package from github

``` r
remotes::install_github("MansMeg/posteriordb", subdir = "rpackage/")
```

Load the R package and load a posterior from the default posteriordb.

``` r
library(posteriordb)
pd <- pdb_default() # Posterior database connection
pn <- posterior_names(pd)
head(pn)
```

    ## [1] "arK-arK"                                
    ## [2] "arma-arma11"                            
    ## [3] "eight_schools-eight_schools_centered"   
    ## [4] "eight_schools-eight_schools_noncentered"
    ## [5] "garch-garch11"                          
    ## [6] "gp_pois_regr-gp_pois_regr"

``` r
po <- posterior("eight_schools-eight_schools_centered", pdb = pd)
po
```

    ## Posterior
    ## 
    ## Data: eight_schools
    ## The 8 schools dataset of Rubin (1981)
    ## 
    ## Model: eight_schools_centered
    ## A centered hiearchical model for 8 schools

From the posterior we can easily access data and models as

``` r
sc <- stan_code(po)
sc
```

    ## 
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
    ##   y ~ normal(theta , sigma);
    ##   mu ~ normal(0, 5);
    ## }

``` r
dat <- get_data(po)
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

Finally we can access gold standard posterior draws and information on
how those were computed as follows.

``` r
rp_info <- reference_posterior_info(po)
rp_info
```

    ## Posterior: eight_schools-eight_schools_noncentered
    ## Method: stan_sampling (rstan 2.19.2)
    ## Arguments:
    ##   chains: 10
    ##   iter: 20000
    ##   warmup: 10000
    ##   thin: 10
    ##   seed: 4711
    ##     adapt_delta: 0.95

``` r
gsd <- reference_posterior_draws(po)
gsd
```

    ## Posterior: eight_schools-eight_schools_noncentered
    ## # A tibble: 10 x 10
    ##    variable  mean median    sd   mad     q5   q95  rhat ess_bulk ess_tail
    ##    <chr>    <dbl>  <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl>    <dbl>    <dbl>
    ##  1 theta[1]  6.23   5.59  5.72  4.48 -1.56  16.4  1.00    10116.    9946.
    ##  2 theta[2]  5.03   4.90  4.67  4.16 -2.40  12.8  1.000    9908.    9992.
    ##  3 theta[3]  3.99   4.26  5.29  4.44 -4.71  11.8  1.000   10329.    9872.
    ##  4 theta[4]  4.78   4.68  4.84  4.29 -2.80  12.7  1.00    10448.   10079.
    ##  5 theta[5]  3.68   3.97  4.70  4.19 -4.47  10.9  1.00    10324.    9788.
    ##  6 theta[6]  3.99   4.13  4.83  4.30 -4.12  11.5  1.000   10195.    9682.
    ##  7 theta[7]  6.40   5.89  5.12  4.37 -0.888 15.6  1.00     9505.    9991.
    ##  8 theta[8]  4.89   4.77  5.28  4.44 -3.23  13.5  1.00     9869.    9515.
    ##  9 mu        4.44   4.47  3.36  3.34 -1.09  10.0  1.000   10374.    9871.
    ## 10 tau       3.60   2.72  3.26  2.53  0.250  9.92 1.00     9866.   10035.

The posterior is based on the
[posterior](https://github.com/jgabry/posterior) R package structure and
can easily be summarized and transformed using the mentioned R package.

``` r
draws_df <- posterior::as_draws_df(gsd$draws)
head(draws_df)
```

    ## # A tibble: 6 x 13
    ##   .chain .iteration .draw `theta[1]` `theta[2]` `theta[3]` `theta[4]`
    ##    <int>      <int> <int>      <dbl>      <dbl>      <dbl>      <dbl>
    ## 1      1          1     1       3.83       3.23      4.68       1.89 
    ## 2      1          2     2       1.99       3.66     -0.296     -0.115
    ## 3      1          3     3      -3.57       5.64      3.70       7.68 
    ## 4      1          4     4       9.40      17.4       8.35      10.9  
    ## 5      1          5     5       2.01       3.43      3.74       1.32 
    ## 6      1          6     6       5.95       6.08      7.68       6.25 
    ## # … with 6 more variables: `theta[5]` <dbl>, `theta[6]` <dbl>,
    ## #   `theta[7]` <dbl>, `theta[8]` <dbl>, mu <dbl>, tau <dbl>

Using the posterior database from python
----------------------------------------

See [python README](./python/README.md)

Using the posterior database from R (extensive)
-----------------------------------------------

See [python README](./rpackage/README.md)

Design choices (so far)
-----------------------

The main focus of the database is simplicity in data and model, both in
understanding and in use.

The following are the current design choices in designing the posterior
database.

1.  Priors are hardcoded in model files as changing the prior changes
    the posterior. Create a new model to test different priors.
2.  Data transformations are stored as different datasets. Create new
    data to test different data transformations, subsets, and variable
    settings. This makes the database larger/less memory efficient but
    simplifies the analysis of individual posteriors.
3.  Models and data has (model/data).info.json files with model and data
    specific information.
4.  Templates for different jsons can be found in content/templates and
    schemas in schemas (Note: these don’t exist right now and will be
    added later)
5.  Prefix ‘syn\_’ stands for synthetic data where the generative
    process is known and can be found in content/data-raw.
6.  All data preprocessing is included in content/data-raw.
7.  Specific information for different PPL representations of models is
    included in the PPL syntax files as comments, not in the
    model.info.json files.
