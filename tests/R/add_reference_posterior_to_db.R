library(rstan)
library(posteriordb)
library(posterior)

# Setup refernce posterior info object
mvfp <- file.path(file.path(Sys.getenv("HOME"), ".R"), ifelse(.Platform$OS.type == "windows", "Makevars.win", "Makevars"))
versions <- list(rstan_version = paste("rstan", utils::packageVersion("rstan")),
                 r_Makevars = paste(readLines(mvfp), collapse = "\n"),
                 r_version = R.version.string,
                 r_session = paste(capture.output(sessionInfo()), collapse = "\n"))

rp_info <- list(name = "eight_schools-eight_schools_noncentered",
                inference = list(
                  method = "stan_sampling",
                  method_arguments =
                    list(chains = 10,
                      iter = 20000,
                      warmup = 10000,
                      thin = 10,
                      seed = 4711,
                      control = list(adapt_delta = 0.95))),
                diagnostics = NULL,
                checks_made = NULL,
                comments = NULL,
                added_by = "Måns Magnusson",
                added_date = Sys.Date(),
                versions = versions)
rpi <- reference_posterior_info(rp_info)

# Run model
pdb <- pdb_local()
rfd <- posteriordb:::compute_reference_posterior_draws_stan_sampling(rpi = rpi, pdb)

# Check the reference posterior for the reference posterior definition
rpc <- check_reference_posterior_draws(x = rfd)

# Write the reference posterior to DB
write_pdb(x = rpc, pdb, overwrite = TRUE)
