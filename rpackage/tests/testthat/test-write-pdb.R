context("test-write-pdb")

test_that("write data", {

  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(po <- posterior("eight_schools-eight_schools_centered", pdb_test))
  expect_silent(d <- get_data(po))

  # Test write data
  di <- info(d); di$name <- "test_data"; info(d) <- di
  expect_silent(write_pdb(d, pdb_test))
  expect_error(write_pdb(d, pdb_test))
  expect_silent(write_pdb(d, pdb_test, overwrite = TRUE))

  # Test write data info
  di$name <- "test_data"
  di$title <- di$description <- "Test data"
  di$data_file <- "data/data/test_data.json"

  expect_silent(write_pdb(di, pdb_test, overwrite = TRUE))
  expect_error(write_pdb(di, pdb_test))
  expect_silent(write_pdb(di, pdb_test, overwrite = TRUE))

  info(d) <- di
  expect_silent(dt <- pdb_data("test_data", pdb_test))
  expect_identical(d, dt)
  expect_silent(dti <- pdb_data_info("test_data", pdb_test))

  # Remove test_data
  expect_silent(remove_pdb(x = dt, pdb = pdb_test))
  expect_silent(remove_pdb(x = dti, pdb = pdb_test))
  pdb_clear_cache(pdb_test)
  expect_error(pdb_data("test_data", pdb_test))
  expect_error(pdb_data_info("test_data", pdb_test))
})


test_that("write model", {

  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(po <- posterior("eight_schools-eight_schools_centered", pdb_test))
  expect_silent(sc <- stan_code(po))

  # Test write model info
  mi <- info(sc)
  mi$name <- "test_model"
  mi$title <- mi$description <- "Test model"
  mi$model_implementations <- list(stan = list(model_code = "models/stan/test_model.stan"))

  # Test write model
  info(sc) <- mi
  expect_silent(write_pdb(sc, pdb_test, overwrite = TRUE))
  expect_error(write_pdb(sc, pdb_test))
  expect_silent(write_pdb(sc, pdb_test, overwrite = TRUE))

  expect_silent(sct <- pdb_stan_code("test_model", pdb_test))
  expect_identical(sc, sct)

  # Remove model
  expect_silent(remove_pdb(sc, pdb = pdb_test))
  expect_silent(remove_pdb(mi, pdb = pdb_test))
  pdb_clear_cache(pdb_test)
  expect_error(pdb_model_code("test_model", pdb_test, "stan"))
  expect_error(pdb_model_info("test_model", pdb_test))

  # Write model info
  expect_silent(write_pdb(mi, pdb_test))
  expect_error(write_pdb(mi, pdb_test))
  expect_silent(write_pdb(mi, pdb_test, overwrite = TRUE))

  expect_silent(mit <- pdb_model_info("test_model", pdb_test))
  expect_identical(mi, mit)

  # Remove model info
  expect_silent(remove_pdb(mi, pdb = pdb_test))
  pdb_clear_cache(pdb_test)
  expect_error(pdb_model_info("test_model", pdb_test))
})





test_that("write posterior", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(po <- posterior("eight_schools-eight_schools_centered", pdb_test))
  expect_silent(sc <- stan_code(po))
  expect_silent(d <- pdb_data(po))

  # Test write model info
  info(sc)$name <- "test_model"
  info(d)$name <- "test_data"

  # Test write gsd
  po$name <- "test_data-test_model"
  po$model_name <- "test_model"
  po$data_name <- "test_data"
  po["reference_posterior_name"] <- list(NULL)
  po$model_info <- info(sc)
  po$data_info <- info(d)

  expect_silent(write_pdb(po, pdb_test))
  expect_error(write_pdb(po, pdb_test))
  expect_silent(write_pdb(po, pdb_test, overwrite = TRUE))

  # Test that we get identical posteriors
  write_pdb(d, pdb_test)
  write_pdb(sc, pdb_test)
  expect_silent(pot <- posterior("test_data-test_model", pdb_test))
  expect_identical(po, pot)

  # Remove posterior
  expect_silent(remove_pdb(pot, pdb = pdb_test))
  pdb_clear_cache(pdb_test)
  expect_error(posterior("test_data-test_model", pdb_test))

  remove_pdb(sc, pdb = pdb_test)
  remove_pdb(info(sc), pdb = pdb_test)
  remove_pdb(d, pdb = pdb_test)
  remove_pdb(info(d), pdb = pdb_test)

})



test_that("write reference_posterior", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(po <- posterior("eight_schools-eight_schools_centered", pdb_test))
  expect_silent(gsi <- reference_posterior_draws_info(po))
  expect_silent(gsd <- reference_posterior_draws(po))

  # Setup posterior
  # This is needed to access the created reference posterior
  # since it uses posterior() to access the test reference posterior
  po$name <- "test_data-test_model"
  po$reference_posterior_name <- po$name
  write_pdb(po, pdb_test)

  # Test write gsd
  info(gsd)$name <- "test_data-test_model"
  expect_silent(write_pdb(gsd, pdb_test))
  expect_error(write_pdb(gsd, pdb_test))
  expect_silent(write_pdb(gsd, pdb_test, overwrite = TRUE))

  expect_silent(rpt <- pdb_reference_posterior_draws(x = "test_data-test_model", pdb_test))
  expect_identical(gsd, rpt)

  # Remove rpd
  expect_silent(remove_pdb(rpt, pdb = pdb_test))
  expect_silent(remove_pdb(info(rpt), pdb = pdb_test, type = "draws"))
  pdb_clear_cache(pdb_test)
  expect_error(pdb_reference_posterior_draws("test_data-test_model", pdb_test))

  # Test write gsi
  gsi$name <- "test_data-test_model"
  expect_silent(write_pdb(gsi, pdb_test, type = "draws"))
  expect_error(write_pdb(gsi, pdb_test, type = "draws"))
  expect_silent(write_pdb(gsi, pdb_test, overwrite = TRUE, type = "draws"))

  expect_silent(rpi <- pdb_reference_posterior_draws_info(x = "test_data-test_model", pdb_test))
  expect_identical(gsi, rpi)
  expect_silent(remove_pdb(rpi, pdb = pdb_test, type = "draws"))

  # Cleanup
  remove_pdb(po, pdb_test)
})
