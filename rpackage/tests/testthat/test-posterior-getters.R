context("test-posterior-getters")

test_that("Check that all posteriors can access stan_data and stan_code", {

  posterior_db_path <- posteriordb:::get_test_pdb_dir()

  expect_silent(pdb_test <- pdb(posterior_db_path))

  expect_silent(po <- posterior("eight_schools-eight_schools_noncentered", pdb = pdb_test))

  # Test stan_data_file_path
  expect_silent(sdfp <- stan_data_file_path(po))
  expect_true(file.exists(sdfp))
  if(!on_windows()) expect_true(grepl(pattern = tempdir(), x = sdfp))
  expect_equal(posteriordb:::get_file_extension(sdfp), "json")
  expect_silent(jsonlite::read_json(sdfp))

  # Test data_info
  expect_silent(di <- data_info(po))
  expect_s3_class(di, "pdb_data_info")
  expect_output(print(di), "Data: eight_schools")

  # Test model_code
  expect_silent(mcfp <- model_code_file_path(po, "stan"))
  expect_true(file.exists(mcfp))
  if(!on_windows()) expect_true(grepl(pattern = tempdir(), x = mcfp))
  expect_equal(posteriordb:::get_file_extension(mcfp), "stan")
  expect_silent(scfp <- stan_code_file_path(po))
  expect_equal(scfp, mcfp)

  # Test model_code
  expect_silent(mc <- model_code(po, framework = "stan"))
  expect_s3_class(mc, "pdb_model_code")
  expect_output(print(mc), "data \\{")
  expect_output(print(mc), "parameters \\{")
  expect_output(print(mc), "model \\{")

  # Test stan_code
  expect_silent(sc <- stan_code(po))
  expect_s3_class(sc, "pdb_model_code")
  expect_equal(sc, mc)

  # Test model_info
  expect_silent(mi <- model_info(po))
  expect_s3_class(mi, "pdb_model_info")
  expect_output(print(mi), "Model: eight_schools_noncentered")

  expect_output(print(po), "Posterior")

  # Get posteriors draws directly
  expect_silent(gsd <- reference_posterior_draws(po))
  expect_silent(gsi <- reference_posterior_draws_info(po))

})



test_that("Check access only with posterior name", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()

  expect_silent(pdb_test <- pdb(posterior_db_path))

  # Test stan_data_file_path
  expect_silent(di <- data_info("eight_schools", pdb_test))
  expect_silent(d1 <- get_data("eight_schools", pdb_test))
  expect_silent(d2 <- get_data(di, pdb_test))
  expect_identical(d1,d2)
  expect_silent(sdfp <- data_file_path("eight_schools", pdb_test))
  expect_silent(sdfp <- data_file_path(di, pdb_test))
  expect_true(file.exists(sdfp))

  # Test model_code/stan_code
  expect_silent(mi <- model_info("eight_schools_noncentered", pdb = pdb_test, framework = "stan"))
  expect_silent(sc1 <- stan_code("eight_schools_noncentered", pdb = pdb_test))
  expect_silent(sc2 <- stan_code(mi, pdb = pdb_test))
  expect_identical(sc1,sc2)
  expect_silent(mcfp <- model_code_file_path("eight_schools_noncentered", pdb = pdb_test, framework = "stan"))
  expect_silent(mcfp <- model_code_file_path(mi, pdb = pdb_test, framework = "stan"))
  expect_true(file.exists(mcfp))

  # Test reference_posterior
  expect_silent(gsi <- reference_posterior_draws_info("eight_schools-eight_schools_noncentered", pdb = pdb_test))
  expect_silent(gsd1 <- reference_posterior_draws("eight_schools-eight_schools_noncentered", pdb = pdb_test))
  expect_silent(gsd2 <- reference_posterior_draws(x = gsi, pdb = pdb_test))
  expect_identical(gsd1,gsd2)
  expect_silent(gsdfp <- reference_posterior_draws_file_path("eight_schools-eight_schools_noncentered", pdb = pdb_test))
  expect_silent(gsdfp <- reference_posterior_draws_file_path(gsi, pdb = pdb_test))
})



test_that("Check access only with posterior name and default pdb", {

  skip_if(is.null(github_pat()))

  # Test stan_data_file_path
  expect_silent(di <- data_info("eight_schools"))
  expect_silent(d1 <- get_data("eight_schools"))
  expect_silent(d2 <- get_data(di))
  expect_silent(sdfp <- data_file_path("eight_schools"))
  expect_silent(sdfp <- data_file_path(di))

  # Test model_code/stan_code
  expect_silent(mi <- model_info("eight_schools_noncentered", framework = "stan"))
  expect_silent(sc1 <- stan_code("eight_schools_noncentered"))
  expect_silent(sc2 <- stan_code(mi))
  expect_silent(mcfp <- model_code_file_path("eight_schools_noncentered", framework = "stan"))
  expect_silent(mcfp <- model_code_file_path(mi, framework = "stan"))

  # Test reference_posterior
  expect_silent(gsi <- reference_posterior_draws_info("eight_schools-eight_schools_noncentered"))
  expect_silent(gsd1 <- reference_posterior_draws("eight_schools-eight_schools_noncentered"))
  expect_silent(gsd2 <- reference_posterior_draws(x = gsi))
  expect_silent(gsdfp <- reference_posterior_draws_file_path("eight_schools-eight_schools_noncentered"))
  expect_silent(gsdfp <- reference_posterior_draws_file_path(gsi))

})



test_that("Check that model_code, data and reference_posteriors contain a pdb attr", {

  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))

  expect_silent(po <- posterior("eight_schools-eight_schools_noncentered", pdb = pdb_test))
  expect_identical(pdb(po), pdb_test)

  expect_silent(d <- get_data(po))
  expect_identical(pdb(d), pdb_test)

  expect_silent(mc <- stan_code(po))
  expect_identical(pdb(mc), pdb_test)

  expect_silent(rp <- reference_posterior_draws(po))
  expect_identical(pdb(rp), pdb_test)

})
