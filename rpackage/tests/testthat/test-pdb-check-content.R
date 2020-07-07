context("test-pdb-check-content")

test_that("check_pdb_read_posteriors", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(pdb_clear_cache(pdb_test))

  expect_silent(check_pdb_read_posteriors(pdb_test))
})


test_that("check_pdb_read_model_code", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))

  expect_silent(pl <- check_pdb_read_posteriors(pdb_test))
  expect_silent(check_pdb_read_model_code(pl))
})


test_that("check_pdb_read_model_code", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))

  expect_silent(pl <- check_pdb_read_posteriors(pdb_test))
  skip_on_travis()
  expect_silent(check_pdb_read_data(pl))
})

test_that("check_pdb_read_reference_posterior_draws", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))

  expect_silent(pl <- check_pdb_read_posteriors(pdb_test))
  skip_on_travis()
  expect_silent(check_pdb_read_reference_posterior_draws(pl))
})


test_that("check_pdb_aliases", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))

  expect_silent(check_pdb_aliases(pdb_test))
})

test_that("check_pdb_references", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))

  expect_message(check_pdb_references(pdb_test))
})

test_that("check_pdb_model_data_ref_in_posteriors", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))

  expect_silent(check_pdb_all_models_have_posterior(pdb_test))
  expect_silent(check_pdb_all_data_have_posterior(pdb_test))
  expect_silent(check_pdb_all_reference_posteriors_have_posterior(pdb_test))
})
