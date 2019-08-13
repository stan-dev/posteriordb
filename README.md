[![Build Status](https://travis-ci.org/MansMeg/posteriordb.svg?branch=master)](https://travis-ci.org/MansMeg/posteriordb)

# A Posterior Database (PDB) for Bayesian Inference

This repository contains data and models to produce posteriors based on different probabilistic programming languages (PPL). Currently the focus is Stan, but it should be possible to use it with other frameworks as well.

## Purpose of the PDB

There are many purposes with the PDB

1. A simple repository to access many models and dataset in a structured way from R and Python
2. Store models and data in a structure that lends itself for testing inference algorithms on a large number of posteriors.
3. A structure that makes it easy for students to access models and data for courses in Bayesian data analysis.
4. A structure that is framework agnostic (although now Stan is in focus) and can be used with many different probabilistic programming frameworks.
5. A structure that simplifies regression testing of probabilistic programming frameworks.

### Future

The future for the posterior database is to:
1. Add python library
2. Add more posteriors
3. Add more gold standards

The long term goal is to move the posterior database to an open RESTful NoSQL database for easy access.

## Design choices (so far)

The following are the current design choices in designing the posterior database.

The main focus with the database is simplicity in data and model, both in understanding and in use.

1. Priors are hardcoded in model files
   Create a new model to test different priors
2. Data transformations are stored as different datasets
   Create a new data to test different data transformations, subsets and variable settings. This makes the database larger/less memory efficient, but simplifies analysis of individual posteriors.
3. Models and data has [model/data].info.json files with model and data specific information.
4. Templates for different jsons can be found in content/templates and schemas in schemas (Note: these don't exist right now and will be added later)
5. Prefix 'syn_' stands for synthetic data where the generative process is known and can be found in content/data-raw
6. All data preprocessing is included in the data-raw folder
7. Specific information for different PPL representations of models are included in the PPL syntax files as comments, not in the model.info.json files.

### Add a posterior to the database

Fork and submit it as a PR.

## Using the posterior database from R (with the R package)

The included database contain convinience functions to access data, stan code and information for individual posteriors.

To install the package, simply use clone this repository and use run the following snippet to install the package in the cloned folder. The R package do not contain the content of the posterior database and hence the repository needs to be cloned.

```
devtools::install("rpackage/")
library(pdb)
```

First we create the posterior database to use, here the cloned posterior database.
```
my_pdb <- pdb(getwd())
```

To list the posteriors available, just use `posterior_names()`
```
> pos <- posterior_names(my_pdb)
> head(pos)

[1] "8_schools-8_schools_centered"                               
[2] "8_schools-8_schools_noncentered"                            
[3] "prideprejustice_chapter-ldaK5"                    
[4] "prideprejustice_paragraph-ldaK5"                  
[5] "radon_mn-radon_hierarchical_intercept_centered"   
[6] "radon_mn-radon_hierarchical_intercept_noncentered"
```

In the same fashion we can list data and models included in the database as

```
> mn <- model_names(my_pdb)
> head(mn)

 [1] "8_schools_centered"                        
 [2] "8_schools_noncentered"                     
 [3] "blr"                                       
 [4] "gmm_diagonal_nonordered"                   
 [5] "gmm_diagonal_ordered"                      
 [6] "gmm_nonordered" 

> dn <- dataset_names(my_pdb)
> head(dn)

[1] "8_schools"                 "prideprejustice_chapter"   "prideprejustice_paragraph"
[4] "radon_mn"                  "radon"                     "roaches_scaled"

```

The posteriors name is setup of the posterior data and the model. To access a posterior we can use the model name.

```
po <- posterior("8_schools-8_schools_centered", my_pdb)
```

From the posterior object we can access data, stan code and information.

```
> dataset(po)
$J
[1] 8

$y
[1] 28  8 -3  7 -1  1 18 12

$sigma
[1] 15 10 16 11  9 11 10 18

> sc <- stan_code(po)
> head(sc)

[1] ""                                                    
[2] "data {"                                              
[3] "  int <lower=0> J; // number of schools"             
[4] "  real y[J]; // estimated treatment"                 
[5] "  real<lower=0> sigma[J]; // std of estimated effect"
[6] "}" 
```

We can also access the paths to data after they have been unzipped and copied to the R temp directory. By default stan code is also copied to the R temp directory

```
> dfp <- dataset_file_path(po)
> dfp

"/var/folders/9h/yf354vb917z6gr6mz7bfb1d40000gn/T//RtmpCmhFba/posteriors/data/8_schools.json"

> scfp <- stan_code_file_path(po)
> scfp

"/var/folders/9h/yf354vb917z6gr6mz7bfb1d40000gn/T//RtmpCmhFba/posteriors/stan_code/8_schools_centered.stan"

```

We can also access information regarding the model and the data used to compute the posterior.

```
> data_info(po)

$title
[1] "The 8 schools dataset of Rubin (1981)"

$description
[1] "A study for the Educational Testing Service to analyze the effects of\nspecial coaching programs on test scores. See Gelman et. al. (2014), Section 5.5 for details."

$urls
$urls[[1]]
[1] "http://www.stat.columbia.edu/~gelman/arm/examples/schools"

$references
$references[[1]]
[1] "rubin1981estimation"
$references[[2]]
[1] "gelman2013bayesian"

$keywords
$keywords[[1]]
[1] "bda3_example"



> model_info(po)
$title
[1] "A centered hiearchical model for 8 schools"

$description
[1] "A centered hiearchical model for the 8 schools example of Rubin (1981)"

$urls
$urls[[1]]
[1] "http://www.stat.columbia.edu/~gelman/arm/examples/schools"

$references
$references[[1]]
[1] "rubin1981estimation"
$references[[2]]
[1] "gelman2013bayesian"

$keywords
$keywords[[1]]
[1] "bda3_example"

$keywords[[2]]
[1] "hiearchical"

```

Note that the references are referencing to bibtex items that can be found in `content/references/references.bib`.


## Content

The database contain

1. `posteriors`: A folder with the different posteriors as json slots pointing to data and models
2. The content folder contains (this part is not stable and may change)

  a. `content/data`: The data used in the models
  
  b. `content/data-raw`: Data used to generate the data in the data folder with reproducible code (may be git submodule further along).
  
  c. `content/models`: The models used in different PPF
  
  d. `content/posterior_gold_standards`: A folder with different posterior draws (may be git submodule further along).
  
  e. `content/schemas`: json schemas used in the database
  
  f. `content/templates`: json templates for objects used in the database  




