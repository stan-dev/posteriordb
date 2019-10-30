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

### Future

In the immediate future, we plan to

1.  Add more posteriors
2.  Add more gold standards

The long term goal is to move the posterior database to an open RESTful
NoSQL database for easy access.

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

### Add a posterior to the database

Fork and submit it as a PR.

Using the posterior database from python
----------------------------------------

See [python README](./python/README.md)

Using the posterior database from R (with the R package)
--------------------------------------------------------

The included database contains convenience functions to access data,
model code and information for individual posteriors.

To install the package, clone this repository and run the following
snippet to install the package in the cloned folder. The R package does
not contain the content of the posterior database and hence the
repository needs to be cloned.

``` r
devtools::install("rpackage/")
```

``` r
library(posteriordb)
```

First we create the posterior database to use, here we can use the
database locally (after cloning the repo).

``` r
my_pdb <- pdb_local()
```

The above code requires that your working directory is in the main
folder of your copy of this project. We can also simply use the github
repository directly.

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

    ## [1] "eight_schools-eight_schools_centered"             
    ## [2] "eight_schools-eight_schools_noncentered"          
    ## [3] "prideprejustice_chapter-ldaK5"                    
    ## [4] "prideprejustice_paragraph-ldaK5"                  
    ## [5] "radon_mn-radon_hierarchical_intercept_centered"   
    ## [6] "radon_mn-radon_hierarchical_intercept_noncentered"

In the same fashion, we can list data and models included in the
database as

``` r
mn <- model_names(my_pdb)
head(mn)
```

    ## [1] "blr"                       "eight_schools_centered"   
    ## [3] "eight_schools_noncentered" "gmm_diagonal_nonordered"  
    ## [5] "gmm_diagonal_ordered"      "gmm_nonordered"

``` r
dn <- data_names(my_pdb)
head(dn)
```

    ## [1] "eight_schools"             "prideprejustice_chapter"  
    ## [3] "prideprejustice_paragraph" "radon_mn"                 
    ## [5] "radon"                     "roaches_scaled"

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

    ## [1] "/var/folders/9h/yf354vb917z6gr6mz7bfb1d40000gn/T//RtmpcCcnlk/posteriordb_cache/data/data/eight_schools.json"

``` r
scfp <- stan_code_file_path(po)
scfp
```

    ## [1] "/var/folders/9h/yf354vb917z6gr6mz7bfb1d40000gn/T//RtmpcCcnlk/posteriordb_cache/models/stan/eight_schools_centered.stan"

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

To access gold standard posterior draws we can use the function
`gold_standard()` as follows.

``` r
gs <- gold_standard(po)
draws <- posterior_draws(gs)
head(draws[, 1:3])
```

    ##      theta.1  theta.2   theta.3
    ## 1  3.5027341 8.618518  9.967790
    ## 2 -0.8378876 7.734585 -4.979401
    ## 3  4.8066627 6.400773  6.547035
    ## 4  2.8120378 3.366140  2.647097
    ## 5  1.8940634 5.463313 11.866009
    ## 6  3.9630204 3.807904  3.976421

Content
-------

See
[DATABASE\_CONTENT.md](https://github.com/MansMeg/posteriordb/blob/master/DATABASE_CONTENT.md)
for the details content of the posterior database.
