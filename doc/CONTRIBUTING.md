Contributing
============

We are happy for you to contribute with code or new posteriors to the database. Just create a Pull Request with your new content to the posteriordb; the content will be checked using Travis CI.

Don't hesitate to make a Pull Request (PR) with a new model, data, or posterior to the repository. We use the PR for discussion on new material!

Copyright
-------------
All models supplied will use the BD3 license by default (see R package). It is possible to manually specify a license in data, model or reference posterior info object.

Pull request workflow
-------------

1. Fork this repository
1. Make a contribution
1. Open a pull request in GitHub (the tests will the automatically run on Travis)


CONTRIBUTING CONTENT
-------------

It is currently much simpler to add new content through R, but hopefully, this will be simplified further on.

## Add content through R

Start by installing and loading the posteriordb R package. We then

```
devtools::install_local("rpackage/")
library(posteriordb)
library(rstan)

# We setup a connection to the local posteriordb
pdbl <- pdb_local()
```

### Add Data

The next step is to add and write down information about the data. Below is a test example using data from the eight schools example.

```
x <- list(name = "test_eight_schools_data",
          keywords = c("test_data"),
          title = "A Test Data for the Eight Schools Model",
          description = "The data contain data from eight schools on SAT scores.",
          urls = "https://cran.r-project.org/web/packages/rstan/vignettes/rstan.html",
          references = "testBiBTeX2020",
          added_date = Sys.Date(),
          added_by = "Stanislaw Ulam")

# Create the data info object
di <- pdb_data_info(x)

# Access the data
file_path <- system.file("test_files/eight_schools.R", package = "posteriordb")
source(file_path)

# Create the data object
dat <- pdb_data(eight_schools, info = di)
```

We can now add the data object to the database (or remove it). The function ```write_pdb()``` will write and zip the data.

```
write_pdb(dat, pdbl)
# We can then remove the data from the database in a similar way.
# remove_pdb(dat, pdbl)
```

### Add Model

Similarly, we can add stan-files and model information as follows: a test case using the eight school model.

```
x <- list(name = "test_eight_schools_model",
          keywords = c("test_model", "hiearchical"),
          title = "Test Non-Centered Model for Eight Schools",
          description = "An hiearchical model, non-centered parametrisation.",
          urls = c("https://cran.r-project.org/web/packages/rstan/vignettes/rstan.html"),
          framework = "stan",
          references = NULL,
          added_by = "Stanislaw Ulam",
          added_date = Sys.Date())
mi <- pdb_model_info(x)

# Read in Stan model and compile the model
file_path <- system.file("test_files/eight_schools_noncentered.stan", package = "posteriordb")
smc <- readLines(file_path)
sm <- rstan::stan_model(model_code = smc)
mc <- model_code(sm, info = mi)

# Write the model to the database
write_pdb(mc, pdbl)

# We can then remove the data from the database with:
# remove_pdb(mc, pdbl)
```

### Add Posterior Object
```
x <- list(pdb_model_code = mc,
          pdb_data = dat,
          keywords = "posterior_keywords",
          urls = "posterior_urls",
          references = "posterior_references",
          dimensions = list("dimensions" = 2, "dim" = 3),
          reference_posterior_name = NULL,
          added_date = Sys.Date(),
          added_by = "Stanislaw Ulam")
po <- pdb_posterior(x, pdbl)

# We write to the database as done previously
write_pdb(po, pdbl)
# To remove the posterior, we use:
# remove_pdb(po, pdbl)
```

Finally, we want to check that everything is in order with the posterior. We do this as follows:

```
check_posterior(po)
```
We have not added `testBiBTeX2020` to the bibliography, and hence the function throws an error.

If the posterior passes all checks, it can be added to the posteriordb, so it is just to open a Pull Request with the proposed posterior.


### Add Posterior Reference Draws

If possible, we would like to supply posterior reference draws, i.e., draws of excellent quality from the posterior. The [REFERENCE_POSTERIOR_DEFINITION.md](https://github.com/MansMeg/posteriordb/blob/master/doc/REFERENCE_POSTERIOR_DEFINITION.md) contain details on quality criteria for reference posteriors.

```
pdbl <- pdb_local()
po <- posterior("test_eight_schools_data-test_eight_schools_model", pdbl)

# Access the Makevar for reproducibility
M <- file.path(Sys.getenv("HOME"), ".R", ifelse(.Platform$OS.type == "windows", "Makevars.win", "Makevars"))
Mfile <- if(file.exists(M)) paste(readLines(M), collapse = "\n") else ""

# Setup reference posterior info ----
x <- list(name = posterior_name(po),
          inference = list(method = "stan_sampling",
                           method_arguments = list(chains = 10,
                                                   iter = 20000,
                                                   warmup = 10000,
                                                   thin = 10,
                                                   seed = 4711,
                                                   control = list(adapt_delta = 0.92))),
          diagnostics = NULL,
          checks_made = NULL,
          comments = "This is a test reference posterior",
          added_by = "Stanislaw Ulam",
          added_date = Sys.Date(),
          versions = list(rstan_version = paste("rstan", utils::packageVersion("rstan")),
                          r_Makevars = paste(readLines("~/.R/Makevars"), collapse = "\n"), # This works for macosx
                          r_version = R.version$version.string,
                          r_session = paste(capture.output(print(sessionInfo())), collapse = "\n")))

# Create a reference posterior draws info object
rpi <- pdb_reference_posterior_draws_info(x)
```

The reference posterior draws info contain all information to compute the posterior using rstan. We then check that the reference posterior criteria are fulfilled and add checked diagnostics to the object.

```
# Compute the reference posterior
rp <- compute_reference_posterior_draws(rpi, pdbl)
rp <- check_reference_posterior_draws(x = rp)
```

We can now write the reference posterior draws to the posteriordb.

````
write_pdb(rp, pdbl, overwrite = TRUE)
# To remove the object, just run:
# remove_pdb(rp, pdbl)
````


## Add content directly

It is possible to add content directly to the database by manually specifying the JSON objects. A simple approach is to use eight_schools posterior as a template.



Pre-commit and Tests
====================

Below are more details on how to run pre-commits for code cleaning and
tests to test your contribution locally before opening up a PR.

Installing pre-commit
--------------

[pre-commit](https://pre-commit.com/) helps catch style issues early so
reviewing PRs can focus on more meaningful parts of the PR.

Install it with
```bash
python3 -m pip install --user pre-commit
```
Your system needs to have Python 3.6 or higher.

Check that it works correctly.

```
pre-commit run --all-files
```

Install pre-commit hooks

```bash
pre-commit install
```

Now, pre-commit hooks get run when you `git commit`. For example, if a file
that you are committing has trailing whitespace `pre-commit` will remove
the trailing whitespace, abort the commit and let you stage the modifications.
Then you can run `git commit` again.

All the checks are also run by continuous integration when you make a pull request.
These checks mean that you don't necessarily have to use `pre-commit` locally.
However, we suggest using it locally as that gives more immediate feedback.


Tests
-----------

See python and R test sections.

### Python tests


1. Install `tox`: `pip install tox`
1. Run
   ```bash
   tox
   ```
   Tox automatically configures several python versions and runs the tests on each of them.
   **NOTE**: python 3.6 and python 3.7 need to be installed.

   It is also fine to run on just one python version if, for example, you don't have
   all the versions installed locally. (as continuous integration will cover
   running on all versions)
   ```bash
   tox -e py36, linting
   ```
   This bash script runs the tests on python3.6 and also runs the linting step.

### R tests

See ```rpackage/tests```.
