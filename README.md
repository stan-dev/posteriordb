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

Using the posterior database from python
----------------------------------------

See [python README](./python/README.md)

Using the posterior database from R (with the R package)
--------------------------------------------------------

The included database contains convenience functions to access data,
model code and information for individual posteriors.

To install the package, you can either clone this repository and run the
following snippet to install the package in the cloned folder. The R
package does not contain the content of the posterior database and hence
the repository needs to be cloned.

``` r
remotes::install("rpackage/")
```

It is also possible to install only the R package and then access the
posteriors remotely.

``` r
remotes::install_github("MansMeg/posteriordb", subdir = "rpackage/")
```

To load the package, just run.

``` r
library(posteriordb)
```

First we create the posterior database to use, here we can use the
database locally (if the repo is cloned).

``` r
my_pdb <- pdb_local()
```

The above code requires that your working directory is in the main
folder of the cloned repository. Otherwise we can use the `path`
argument.

We can also simply use the github repository directly to access the
data.

``` r
my_pdb <- pdb_github()
```

Independent of the posterior database used, the following works for all.

To list the posteriors available in the database, use
`posterior_names()`.

``` r
pos <- posterior_names(my_pdb)
head(pos)
```

    ## [1] "arK-arK"                                
    ## [2] "arma-arma11"                            
    ## [3] "eight_schools-eight_schools_centered"   
    ## [4] "eight_schools-eight_schools_noncentered"
    ## [5] "garch-garch11"                          
    ## [6] "gp_pois_regr-gp_pois_regr"

In the same fashion, we can list data and models included in the
database as

``` r
mn <- model_names(my_pdb)
head(mn)
```

    ## [1] "arK"                       "arma11"                   
    ## [3] "eight_schools_centered"    "eight_schools_noncentered"
    ## [5] "garch11"                   "gp_pois_regr"

``` r
dn <- data_names(my_pdb)
head(dn)
```

    ## [1] "arK"           "arma"          "eight_schools" "garch"        
    ## [5] "gp_pois_regr"  "irt_2pl"

We can also get all information on each individual posterior as a tibble
with

``` r
pos <- posteriors_tbl_df(my_pdb)
head(pos)
```

    ## # A tibble: 6 x 7
    ##   name   model_name gold_standard_n… data_name added_by added_date keywords
    ##   <chr>  <chr>      <chr>            <chr>     <chr>    <date>     <chr>   
    ## 1 arK-a… arK        arK-arK          arK       Mans Ma… 2019-11-19 stan_be…
    ## 2 arma-… arma11     arma-arma11      arma      Mans Ma… 2019-11-19 stan_be…
    ## 3 eight… eight_sch… eight_schools-e… eight_sc… Mans Ma… 2019-08-12 stan_be…
    ## 4 eight… eight_sch… eight_schools-e… eight_sc… Mans Ma… 2019-08-12 stan_be…
    ## 5 garch… garch11    garch-garch11    garch     Mans Ma… 2019-11-19 stan_be…
    ## 6 gp_po… gp_pois_r… gp_pois_regr-gp… gp_pois_… Mans Ma… 2019-11-20 stan_be…

The posterior’s name is made up of the data and model fitted to the
data. Together, these two uniquely define a posterior distribution. To
access a posterior object we can use the model name.

``` r
po <- posterior("eight_schools-eight_schools_centered", my_pdb)
```

From the posterior object, we can access data, model code (i.e., Stan
code in this case) and a lot of other useful information.

``` r
dat <- get_data(po)
str(dat)
```

    ## List of 3
    ##  $ J    : int 8
    ##  $ y    : int [1:8] 28 8 -3 7 -1 1 18 12
    ##  $ sigma: int [1:8] 15 10 16 11 9 11 10 18

``` r
code <- stan_code(po)
code
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

We can also access the paths to data after they have been unzipped and
copied to the R temp directory. By default, the model code is copied to
the R temp directory.

``` r
dfp <- data_file_path(po)
dfp
```

    ## [1] "/var/folders/9h/yf354vb917z6gr6mz7bfb1d40000gn/T//RtmptE97ZB/posteriordb_cache/data/data/eight_schools.json"

``` r
scfp <- stan_code_file_path(po)
scfp
```

    ## [1] "/var/folders/9h/yf354vb917z6gr6mz7bfb1d40000gn/T//RtmptE97ZB/posteriordb_cache/models/stan/eight_schools_centered.stan"

We can also access information regarding the model and the data used to
compute the posterior.

``` r
data_info(po)
```

    ## Data: eight_schools
    ## The 8 schools dataset of Rubin (1981)

``` r
model_info(po)
```

    ## Model: eight_schools_centered
    ## A centered hiearchical model for 8 schools

Note that the references are referencing to BibTeX items that can be
found in `content/references/references.bib`.

We can also access a list of posteriors with `filter_posteriors()`. The
filtering function follows dplyr filter semantics based on the posterior
tibble.

``` r
tbl <- posteriors_tbl_df(my_pdb)
head(tbl)
```

    ## # A tibble: 6 x 7
    ##   name   model_name gold_standard_n… data_name added_by added_date keywords
    ##   <chr>  <chr>      <chr>            <chr>     <chr>    <date>     <chr>   
    ## 1 arK-a… arK        arK-arK          arK       Mans Ma… 2019-11-19 stan_be…
    ## 2 arma-… arma11     arma-arma11      arma      Mans Ma… 2019-11-19 stan_be…
    ## 3 eight… eight_sch… eight_schools-e… eight_sc… Mans Ma… 2019-08-12 stan_be…
    ## 4 eight… eight_sch… eight_schools-e… eight_sc… Mans Ma… 2019-08-12 stan_be…
    ## 5 garch… garch11    garch-garch11    garch     Mans Ma… 2019-11-19 stan_be…
    ## 6 gp_po… gp_pois_r… gp_pois_regr-gp… gp_pois_… Mans Ma… 2019-11-20 stan_be…

``` r
pos <- filter_posteriors(my_pdb, data_name == "eight_schools")
pos
```

    ## [[1]]
    ## Posterior
    ## 
    ## Data: eight_schools
    ## The 8 schools dataset of Rubin (1981)
    ## 
    ## Model: eight_schools_centered
    ## A centered hiearchical model for 8 schools
    ## 
    ## [[2]]
    ## Posterior
    ## 
    ## Data: eight_schools
    ## The 8 schools dataset of Rubin (1981)
    ## 
    ## Model: eight_schools_noncentered
    ## A non-centered hiearchical model for 8 schools

To access the gold standard posterior we can use the function
`gold_standard_info()` to access information on how the gold standard
posterior was computed. To access gold standard posterior draws we use
`gold_standard_draws()`.

``` r
gs_info <- gold_standard_info(po)
gs_info
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
gsd <- gold_standard_draws(po)
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

The function `gold_standard_draws()` returns a posterior `draws_list`
object that can be summarized and transformed using the `posterior`
package.

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
