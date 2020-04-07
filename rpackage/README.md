<!-- README.md is generated from README.Rmd. Please edit that file -->

The included database contains convenience functions to access data,
model code and information for individual posteriors.

Installation
============

To install the package, you can either clone this repository and run the
following snippet to install the package or install the package and
access it from Github directly (see below).

``` r
remotes::install("rpackage/")
```

To install only the R package and then access the posteriors remotely,
just install the package from GitHub.

``` r
remotes::install_github("MansMeg/posteriordb", subdir = "rpackage/")
```

To load the package, just run.

``` r
library(posteriordb)
```

Connect to the posterior database
=================================

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

Access content
==============

To list the posteriors available in the database, use
`posterior_names()`.

``` r
pos <- posterior_names(my_pdb)
head(pos)
```

    ## [1] "8schools"          "arK-arK"           "arK"
    ## [4] "arma-arma11"       "arma"              "diamonds-diamonds"

In the same fashion, we can list data and models included in the
database as

``` r
mn <- model_names(my_pdb)
head(mn)
```

    ## [1] "accel_gp"      "accel_splines" "arK"           "arma11"
    ## [5] "blr"           "diamonds"

``` r
dn <- data_names(my_pdb)
head(dn)
```

    ## [1] "arK"           "arma"          "diamonds"      "earnings"
    ## [5] "eight_schools" "garch"

We can also get all information on each individual posterior as a tibble
with

``` r
pos <- posteriors_tbl_df(my_pdb)
head(pos)
```

    ## # A tibble: 6 x 7
    ##   name     model_name  reference_posteri… data_name added_by added_date keywords
    ##   <chr>    <chr>       <chr>              <chr>     <chr>    <date>     <chr>
    ## 1 eight_s… eight_scho… eight_schools-eig… eight_sc… Mans Ma… 2019-08-12 stan_be…
    ## 2 arK-arK  arK         arK-arK            arK       Mans Ma… 2019-11-19 stan_be…
    ## 3 arK-arK  arK         arK-arK            arK       Mans Ma… 2019-11-19 stan_be…
    ## 4 arma-ar… arma11      arma-arma11        arma      Mans Ma… 2020-01-08 stan_be…
    ## 5 arma-ar… arma11      arma-arma11        arma      Mans Ma… 2019-11-19 stan_be…
    ## 6 diamond… diamonds    NULL               diamonds  Oliver … 2020-02-01 stan_be…

The posterior’s name is made up of the data and model fitted to the
data. Together, these two uniquely define a posterior distribution. To
access a posterior object we can use the model name.

``` r
po <- posterior("eight_schools-eight_schools_centered", my_pdb)
```

From the posterior object, we can access data, model code (i.e., Stan
code in this case) and a lot of other useful information.

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
copied to the cache directory set in `pdb` (the R temp directory by
default).

``` r
dfp <- data_file_path(po)
dfp
```

    ## [1] "/var/folders/9h/yf354vb917z6gr6mz7bfb1d40000gn/T//RtmphMv3oc/posteriordb_cache/data/data/eight_schools.json"

``` r
scfp <- stan_code_file_path(po)
scfp
```

    ## [1] "/var/folders/9h/yf354vb917z6gr6mz7bfb1d40000gn/T//RtmphMv3oc/posteriordb_cache/models/stan/eight_schools_centered.stan"

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

We can access most of the posterior information as a `tbl_df` using

``` r
tbl <- posteriors_tbl_df(my_pdb)
head(tbl)
```

    ## # A tibble: 6 x 7
    ##   name     model_name  reference_posteri… data_name added_by added_date keywords
    ##   <chr>    <chr>       <chr>              <chr>     <chr>    <date>     <chr>
    ## 1 eight_s… eight_scho… eight_schools-eig… eight_sc… Mans Ma… 2019-08-12 stan_be…
    ## 2 arK-arK  arK         arK-arK            arK       Mans Ma… 2019-11-19 stan_be…
    ## 3 arK-arK  arK         arK-arK            arK       Mans Ma… 2019-11-19 stan_be…
    ## 4 arma-ar… arma11      arma-arma11        arma      Mans Ma… 2020-01-08 stan_be…
    ## 5 arma-ar… arma11      arma-arma11        arma      Mans Ma… 2019-11-19 stan_be…
    ## 6 diamond… diamonds    NULL               diamonds  Oliver … 2020-02-01 stan_be…

In addition, we can also access a list of posteriors with
`filter_posteriors()`. The filtering function follows dplyr filter
semantics based on the posterior tibble.

``` r
pos <- filter_posteriors(pdb = my_pdb, data_name == "eight_schools")
pos
```

    ## [[1]]
    ## Posterior
    ##
    ## Data: eight_schools
    ## The 8 schools dataset of Rubin (1981)
    ##
    ## Model: eight_schools_noncentered
    ## A non-centered hiearchical model for 8 schools
    ##
    ## [[2]]
    ## Posterior
    ##
    ## Data: eight_schools
    ## The 8 schools dataset of Rubin (1981)
    ##
    ## Model: eight_schools_centered
    ## A centered hiearchical model for 8 schools

To access reference posterior draws we use
`reference_posterior_draws()`.

``` r
rpd <- reference_posterior_draws(po)
```

The function `reference_posterior_draws()` returns a posterior
`draws_list` object that can be summarized and transformed using the
`posterior` package.

``` r
posterior::summarize_draws(rpd)
```

    ## # A tibble: 10 x 10
    ##    variable  mean median    sd   mad      q5   q95  rhat ess_bulk ess_tail
    ##    <chr>    <dbl>  <dbl> <dbl> <dbl>   <dbl> <dbl> <dbl>    <dbl>    <dbl>
    ##  1 theta[1]  5.85   6.04  3.74  2.40 -0.126  10.4  0.941        5        5
    ##  2 theta[2] 11.2    8.22  9.19  3.49  4.72   27.5  1.05         5        5
    ##  3 theta[3]  7.97   6.87  5.11  4.54  2.71   16.6  1.01         5        5
    ##  4 theta[4]  7.05   6.22  8.29  6.00 -1.97   20.3  1.27         5        5
    ##  5 theta[5]  4.91   4.15  4.11  3.18  0.0617 11.1  0.905        5        5
    ##  6 theta[6]  5.16   5.93  3.70  3.68  0.459  10.2  1.30         5        5
    ##  7 theta[7]  5.84   5.25  4.08  4.44 -0.232  11.3  1.42         5        5
    ##  8 theta[8]  6.05   4.47  9.88  2.82 -4.86   22.1  1.02         5        5
    ##  9 mu        5.67   5.44  4.88  4.80  0.302  13.3  1.06         5        5
    ## 10 tau       6.15   6.09  2.24  1.15  3.19    9.65 1.18         5        5

To access information on the reference posterior we can use
`reference_posterior_draws_info()` or just use `info()` on the reference
posterior. This give soime basic information on how the reference
posterior was computed.

``` r
rpi <- reference_posterior_draws_info(po)
rpi
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
