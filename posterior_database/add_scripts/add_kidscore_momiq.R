library(rstan)
library(posteriordb)
library(posterior)

# remotes::install_github("jgabry/posterior")

pdb <- pdb_local("/home/oliver/job/posteriordb/posterior_database/")

# General info
added_by <- "Oliver Järnefelt"

# Data info
data_name <- "kiddiq"
data_keywords <- c("ARM", "Ch. 3", "stan_examples")
data_title <- "Cognitive test scores of three- and four-year-old children"
data_description <- "  - N         : number of observations
  - kid_score : cognitive test scores of three- and four-year-old children
  - mom_hs    : did mother complete high school? 1: Yes, 0: No
  - mom_iq    : mother IQ score
  - mom_hs_new: new data for prediction
  - mom_iq_new: new data for prediction"
data_urls <- c("https://github.com/stan-dev/example-models/tree/master/ARM/Ch.3")
data_references <- "gelman2006data"

# Data
txt <- readLines("https://raw.githubusercontent.com/stan-dev/example-models/master/ARM/Ch.3/kidiq_interaction.data.R")
eval(parse(text = txt)); 
dat <- list(N = N, kid_score = kid_score, mom_hs = mom_hs, mom_iq = mom_iq, mom_hs_new = mom_hs_new, mom_iq_new = mom_iq_new)


# Model
model_name <- "kidscore_momiq"
model_keywords <- c("ARM", "Ch. 3", "stan_examples")
model_title <- "One Predictor Linear Model"
model_description <- "kid_score ~ mom_iq"
model_urls <- c("https://raw.githubusercontent.com/stan-dev/example-models/master/ARM/Ch.3/kidscore_momiq.stan")
model_references <- c("gelman2006data")
model_prior_keywords <- "stan_recommended_35dbfe6"

# Model code
stan_model_code <- readLines("https://raw.githubusercontent.com/stan-dev/example-models/master/ARM/Ch.3/kidscore_momiq.stan")

# Posterior
posterior_keywords <- c("ARM", "Ch. 3", "stan_examples")
posterior_urls <- c("https://github.com/stan-dev/example-models/tree/master/ARM/Ch.3")
posterior_references <- c("gelman2006data")
dimensions <- list(beta = 2L, sigma = 1L)
posterior_name <- paste0(data_name, "-", model_name)


## Create objects ----
# Create data object
class(dat) <- c("pdb_data", "list")
posteriordb:::assert_data(dat)

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
class(di) <- "pdb_data_info"
posteriordb:::assert_data_info(di)

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
class(mi) <- "pdb_model_info"
posteriordb:::assert_model_info(x = mi)

# Create stan model----
sc <- rstan::stan_model(model_name = model_name, model_code = stan_model_code)
checkmate::assert_class(sc, classes = "stanmodel")

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
class(po) <- "pdb_posterior"
posteriordb:::assert_pdb_posterior(po)


# Write objects to pdb ----
write_pdb(di, pdb, overwrite = TRUE)
write_pdb(dat, pdb, name = data_name, overwrite = TRUE)
write_pdb(mi, pdb, overwrite = TRUE)
write_pdb(sc, pdb, overwrite = TRUE)
write_pdb(po, pdb, overwrite = TRUE)

