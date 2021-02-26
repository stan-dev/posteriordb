library(posteriordb)
# remotes::install_github("stan-dev/posterior")
library(posterior)

# Use local pdb to write posterior
pdb <- pdb_local()

# General info
added_by <- "Mans Magnusson"

# Data info
data_name <- "eight_schools"
data_keywords <- c("bda3_example")
data_title <- "The 8 schools dataset of Rubin (1981)"
data_description <- "A study for the Educational Testing Service to analyze the effects of
                     special coaching programs on test scores.
                     See Gelman et. al. (2014), Section 5.5 for details."
data_urls <- c("http://www.stat.columbia.edu/~gelman/arm/examples/schools")
data_references <- c("rubin1981estimation", "gelman2013bayesian")

# Data
txt <- readLines("posterior_database/data/data-raw/eight_schools/eight_schools.R")
eval(parse(text = txt));
dat <- eight_schools


# Model
model_name <- "eight_schools_noncentered"
model_keywords <- c("hiearchical")
model_title <- "A non-centered hiearchical model for 8 schools"
model_description <- "A non-centered hiearchical model for the 8 schools example of Rubin (1981)"
model_urls <- c("http://www.stat.columbia.edu/~gelman/arm/examples/schools")
model_references <- c("rubin1981estimation", "gelman2013bayesian")
model_prior_keywords <- "stan_recommended_35dbfe6"

# Model code
stan_model_code <- readLines("posterior_database/models/stan/eight_schools_noncentered.stan")

# Posterior
posterior_keywords <- c("stan_benchmark")
posterior_urls <- c(NULL)
posterior_references <- c("rubin1981estimation", "gelman2013bayesian")
dimensions <- list(theta = 8L, mu = 1L, tau = 1L)
posterior_name <- paste0(data_name, "-", model_name)



## Create objects ----
# Create data_info_object ----
di <- list(name = data_name,
           keywords = data_keywords,
           title = data_title,
           description = data_description,
           urls = data_urls,
           data_file = paste0("data/data/", data_name, ".json"),
           references = data_references,
           added_date = Sys.Date(),
           added_by = added_by)
di <- pdb_data_info(di)

# Create data object
dat <- pdb_data(dat, info = di)

# Add model to pdb ----
mi <- list(name = model_name,
           keywords = model_keywords,
           title = model_title,
           prior = list(keywords = model_prior_keywords),
           description = model_description,
           urls = model_urls,
           model_implementations =
             list(stan = list(model_code = paste0("models/stan/", model_name, ".stan"))),
           references = model_references,
           added_date = Sys.Date(),
           added_by = added_by)
mi <- pdb_model_info(mi)

# Create stan model----
sc <- rstan::stan_model(model_name = model_name, model_code = stan_model_code)
mc <- pdb_model_code(x = sc, info = mi)

# Add posterior to pdb ----
po <- list(name = paste0(data_name, "-", model_name),
           keywords = posterior_keywords,
           urls = posterior_urls,
           model_name = model_name,
           data_name = data_name,
           reference_posterior_name = NULL,
           references = posterior_references,
           dimensions = dimensions,
           model_info = mi,
           data_info = di,
           pdb = pdb,
           added_date = Sys.Date(),
           added_by = added_by)
po <- pdb_posterior(po)

# Write objects to pdb ----
write_pdb(dat, pdb, overwrite = TRUE)
write_pdb(mc, pdb, overwrite = TRUE)
write_pdb(po, pdb, overwrite = TRUE)
