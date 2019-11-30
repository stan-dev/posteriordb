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
remotes::install_github("MansMeg/posterior", subdir = "rpackage/")
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
    ##   name     model_name   gold_standard_na… data_name added_by added_date keywords
    ##   <chr>    <chr>        <chr>             <chr>     <chr>    <date>     <chr>
    ## 1 arK-arK  arK          arK-arK           arK       Mans Ma… 2019-11-19 stan_be…
    ## 2 arma-ar… arma11       arma-arma11       arma      Mans Ma… 2019-11-19 stan_be…
    ## 3 eight_s… eight_schoo… eight_schools-ei… eight_sc… Mans Ma… 2019-08-12 stan_be…
    ## 4 eight_s… eight_schoo… eight_schools-ei… eight_sc… Mans Ma… 2019-08-12 stan_be…
    ## 5 garch-g… garch11      garch-garch11     garch     Mans Ma… 2019-11-19 stan_be…
    ## 6 gp_pois… gp_pois_regr gp_pois_regr-gp_… gp_pois_… Mans Ma… 2019-11-20 stan_be…

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
copied to the cache directory set in `pdb` (the R temp directory by
default).

``` r
dfp <- data_file_path(po)
dfp
```

    ## [1] "/var/folders/9h/yf354vb917z6gr6mz7bfb1d40000gn/T//RtmpEe7cnB/posteriordb_cache/data/data/eight_schools.json"

``` r
scfp <- stan_code_file_path(po)
scfp
```

    ## [1] "/var/folders/9h/yf354vb917z6gr6mz7bfb1d40000gn/T//RtmpEe7cnB/posteriordb_cache/models/stan/eight_schools_centered.stan"

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
    ##   name     model_name   gold_standard_na… data_name added_by added_date keywords
    ##   <chr>    <chr>        <chr>             <chr>     <chr>    <date>     <chr>
    ## 1 arK-arK  arK          arK-arK           arK       Mans Ma… 2019-11-19 stan_be…
    ## 2 arma-ar… arma11       arma-arma11       arma      Mans Ma… 2019-11-19 stan_be…
    ## 3 eight_s… eight_schoo… eight_schools-ei… eight_sc… Mans Ma… 2019-08-12 stan_be…
    ## 4 eight_s… eight_schoo… eight_schools-ei… eight_sc… Mans Ma… 2019-08-12 stan_be…
    ## 5 garch-g… garch11      garch-garch11     garch     Mans Ma… 2019-11-19 stan_be…
    ## 6 gp_pois… gp_pois_regr gp_pois_regr-gp_… gp_pois_… Mans Ma… 2019-11-20 stan_be…

In addition, we can also access a list of posteriors with
`filter_posteriors()`. The filtering function follows dplyr filter
semantics based on the posterior tibble.

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
    ##   .chain .iteration .draw `theta[1]` `theta[2]` `theta[3]` `theta[4]` `theta[5]`
    ##    <int>      <int> <int>      <dbl>      <dbl>      <dbl>      <dbl>      <dbl>
    ## 1      1          1     1       3.83       3.23      4.68       1.89        5.95
    ## 2      1          2     2       1.99       3.66     -0.296     -0.115       2.16
    ## 3      1          3     3      -3.57       5.64      3.70       7.68        8.97
    ## 4      1          4     4       9.40      17.4       8.35      10.9         4.76
    ## 5      1          5     5       2.01       3.43      3.74       1.32        2.78
    ## 6      1          6     6       5.95       6.08      7.68       6.25        7.22
    ## # … with 5 more variables: `theta[6]` <dbl>, `theta[7]` <dbl>,
    ## #   `theta[8]` <dbl>, mu <dbl>, tau <dbl>
