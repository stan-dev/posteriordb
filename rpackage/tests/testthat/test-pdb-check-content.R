context("test-pdb-check-content")
# This is checks of the content of the database,
# Hence it does not need to run on all systems using CI
if(on_github_actions()) skip_on_os("windows")

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


test_that("check_pdb_read_data", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))

  # Ignore large data on Travis or Appveyor
  if(on_travis() | on_appveyor()){
    ignore_posterior <- "mnist-nn_rbm1bJ100"
  } else {
    ignore_posterior <- character(0)
  }
  expect_silent(pl <- posteriordb:::check_pdb_read_posteriors(pdb_test))

  for (i in seq_along(pl)){
    if(posterior_names(pl[[i]]) %in% ignore_posterior) next
    expect_silent(check_pdb_read_data(list(pl[[i]])))
  }
})

test_that("check_pdb_read_reference_posterior_draws", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))

  expect_silent(pl <- check_pdb_read_posteriors(pdb_test))
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

  if(on_github_actions()) skip_on_os("linux") # Currently problem with stringi on ubuntu (2021-03-10)
  expect_message(check_pdb_references(pdb_test))
})

test_that("check_pdb_model_data_ref_in_posteriors", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))

  expect_silent(check_pdb_all_models_have_posterior(pdb_test))
  expect_silent(check_pdb_all_data_have_posterior(pdb_test))
  expect_silent(check_pdb_all_reference_posteriors_have_posterior(pdb_test))
})
