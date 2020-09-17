context("test-CONTRIBUTING.md")

test_that("CONTRIBUTION.md works as usual (not testing rstan)", {
  skip_on_cran()
  fp_to_CONTRIBUTING_md <- "../../../doc/CONTRIBUTING.md"
  skip_if(!file.exists(fp_to_CONTRIBUTING_md))
  # check hash
  # If this fails, the CONTRIBUTING.md has been changed.
  # Please check that no code has been changed or update this test suite accordingly
  # Then change the hash to the md5 of the new updated file.
  md5_hash <- digest::digest(readLines(fp_to_CONTRIBUTING_md), algo = "md5")
  expect_equal(md5_hash, "c602ccc720e9e75668e45281c1155cc1")

  # Init
  expect_silent(pdbl <- pdb_local())

  # Data
  expect_silent(
    x <- list(name = "test_eight_schools_data",
              keywords = c("test_data"),
              title = "A Test Data for the Eight Schools Model",
              description = "The data contain data from eight schools on SAT scores.",
              urls = "https://cran.r-project.org/web/packages/rstan/vignettes/rstan.html",
              references = "testBiBTeX2020",
              added_date = Sys.Date(),
              added_by = "Stanislaw Ulam")
  )
  expect_silent(di <- pdb_data_info(x))
  expect_silent(file_path <- system.file("test_files/eight_schools.R", package = "posteriordb"))
  expect_silent(eval(parse(file_path)))
  expect_silent(dat <- pdb_data(eight_schools, info = di))
  expect_silent(write_pdb(dat, pdbl))
  # remove_pdb - see below

  # Model
  expect_silent(
    x <- list(name = "test_eight_schools_model",
              keywords = c("test_model", "hiearchical"),
              title = "Test Non-Centered Model for Eight Schools",
              description = "An hiearchical model, non-centered parametrisation.",
              urls = c("https://cran.r-project.org/web/packages/rstan/vignettes/rstan.html"),
              framework = "stan",
              references = NULL,
              added_by = "Stanislaw Ulam",
              added_date = Sys.Date())
    )
  expect_silent(mi <- pdb_model_info(x))
  expect_silent(file_path <- system.file("test_files/eight_schools_noncentered.stan", package = "posteriordb"))
  expect_silent(smc <- readLines(file_path))
  # sm <- rstan::stan_model(model_code = smc)
  # mc <- model_code(sm, info = mi)
  expect_silent(mc <- model_code("eight_schools_noncentered", info = mi, framework = "stan", pdb = pdbl))
  expect_silent(mc <- posteriordb:::`info<-`(mc, mi))
  expect_silent(write_pdb(mc, pdbl))
  # remove_pdb - see below


  # Posterior
  expect_silent(
    x <- list(pdb_model_code = mc,
              pdb_data = dat,
              keywords = "posterior_keywords",
              urls = "posterior_urls",
              references = "posterior_references",
              dimensions = list("dimensions" = 2, "dim" = 3),
              reference_posterior_name = NULL,
              added_date = Sys.Date(),
              added_by = "Stanislaw Ulam")
  )
  expect_silent(po <- pdb_posterior(x, pdbl))
  expect_silent(write_pdb(po, pdbl))
  # remove_pdb - see below
  expect_error(suppressMessages(check_posterior(po, run_stan_code_checks = FALSE)))

  # Posterior draws
  pdbl <- pdb_local()
  po <- posterior("test_eight_schools_data-test_eight_schools_model", pdbl)

  # Setup reference posterior info ----
  expect_silent(
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
  )
  expect_silent(rpi <- pdb_reference_posterior_draws_info(x))
  # rp <- compute_reference_posterior_draws(rpi, pdbl)
  expect_silent(rp <- reference_posterior_draws(x = "eight_schools-eight_schools_noncentered", pdbl))
  rpi$diagnostics <- info(rp)$diagnostics
  expect_silent(rp <- posteriordb:::`info<-`(rp, rpi))
  expect_silent(rp <- check_reference_posterior_draws(x = rp))
  expect_silent(write_pdb(rp, pdbl))
  # remove_pdb - see below

  # Remove test cases from the posteriordb
  expect_silent(remove_pdb(dat, pdbl))
  expect_silent(remove_pdb(mc, pdbl))
  expect_silent(remove_pdb(po, pdbl))
  expect_silent(remove_pdb(rp, pdbl))
})
