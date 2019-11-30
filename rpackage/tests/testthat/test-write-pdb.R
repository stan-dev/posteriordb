context("test-write-pdb")

test_that("write data", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(po <- posterior("eight_schools-eight_schools_centered", pdb_test))
  expect_silent(d <- get_data(po))

  # Test write data
  expect_error(write_pdb(d, pdb_test, name = "test_data", overwrite = TRUE))
  class(d) <- c("pdb_data", "list")
  expect_silent(write_pdb(d, pdb_test, name = "test_data"))
  expect_error(write_pdb(d, pdb_test, name = "test_data"))
  expect_silent(write_pdb(d, pdb_test, name = "test_data", overwrite = TRUE))

  # Test write data info
  di <- po$data_info
  di$name <- "test_data"
  di$title <- di$description <- "Test data"
  di$data_file <- "data/data/test_data.json"

  expect_silent(write_pdb(di, pdb_test))
  expect_error(write_pdb(di, pdb_test))
  expect_silent(write_pdb(di, pdb_test, overwrite = TRUE))

})


test_that("write model", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(po <- posterior("eight_schools-eight_schools_centered", pdb_test))
  expect_silent(sc <- stan_code(po))

  if(FALSE){
    sm <- rstan::stan_model(model_name = "test_model", model_code = sc)
    saveRDS(sm, "test_model.rds")
  } else {
    sm <- readRDS(test_path("test_files", "test_model.rds"))
  }

  # Test write model
  expect_silent(write_pdb(sm, pdb_test))
  expect_error(write_pdb(sm, pdb_test))
  expect_silent(write_pdb(sm, pdb_test, overwrite = TRUE))

  # Test write model info
  mi <- po$model_info
  mi$name <- "test_model"
  mi$title <- mi$description <- "Test model"
  mi$model_code <- list(stan = "models/stan/test_model.stan")

  expect_silent(write_pdb(mi, pdb_test))
  expect_error(write_pdb(mi, pdb_test))
  expect_silent(write_pdb(mi, pdb_test, overwrite = TRUE))
})



test_that("write gold_standards", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(po <- posterior("eight_schools-eight_schools_centered", pdb_test))
  expect_silent(gsi <- gold_standard_info(po))
  expect_silent(gsd <- gold_standard_draws(po))

  # Test write gsd
  gsd$name <- "test_data-test_model"
  expect_silent(write_pdb(gsd, pdb_test))
  expect_error(write_pdb(gsd, pdb_test))
  expect_silent(write_pdb(gsd, pdb_test, overwrite = TRUE))

  # Test write gsi
  gsi$name <- "test_data-test_model"
  expect_silent(write_pdb(gsi, pdb_test))
  expect_error(write_pdb(gsi, pdb_test))
  expect_silent(write_pdb(gsi, pdb_test, overwrite = TRUE))
})


test_that("write posterior", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(po <- posterior("eight_schools-eight_schools_centered", pdb_test))

  # Test write gsd
  po$name <- "test_posterior"
  po$model_name <- "test_model"
  po$data_name <- "test_data"
  po$gold_standard_name <- "test_data-test_model"

  expect_silent(write_pdb(po, pdb_test))
  expect_error(write_pdb(po, pdb_test))
  expect_silent(write_pdb(po, pdb_test, overwrite = TRUE))

})

test_that("test posterior", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(po1 <- posterior("eight_schools-eight_schools_centered", pdb_test))
  expect_silent(po2 <- posterior("test_posterior", pdb_test))

  expect_identical(get_data(po1), get_data(po2))
  expect_identical(stan_code(po1), stan_code(po2))
  expect_identical(gold_standard_draws(po1)$draws, gold_standard_draws(po2)$draws)

})

test_that("remove test posterior", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))

  expect_silent(posteriordb:::remove_posteriors_from_pdb("test_posterior", pdb = pdb_test))
  expect_silent(posteriordb:::remove_data_from_pdb("test_data", pdb = pdb_test))
  expect_silent(posteriordb:::remove_models_from_pdb("test_model", pdb = pdb_test))
  expect_silent(posteriordb:::remove_gold_standards_from_pdb("test_data-test_model", pdb = pdb_test))
  posteriordb:::pdb_clear_cache(pdb_test)

  expect_error(po2 <- posterior("test_posterior", pdb_test))
})
