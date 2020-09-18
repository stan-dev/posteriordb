context("test-pdb_github")

test_that("posteriordb:::check_pdb indicates that github PDB is ok", {
  skip_on_appveyor()
  skip_if(is.null(github_pat()))

  expect_silent(pdb_github_test <- pdb_github("MansMeg/posteriordb/posterior_database"))
  expect_output(print(pdb_github_test), "Posterior Database")
  expect_output(print(pdb_github_test), "github")
  posteriordb:::pdb_clear_cache(pdb_github_test)
  expect_message(posteriordb:::check_pdb(pdb = pdb_github_test, posterior_idx = 1), "Posterior database is ok")
  expect_message(posteriordb:::check_pdb(pdb = pdb_github_test, posterior_idx = 1), "Posterior database is ok")
})

test_that("model_names, data_names and posterior_names work", {
  skip_on_appveyor()
  skip_if(is.null(github_pat()))

  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  posteriordb:::pdb_clear_cache(pdb_test)
  expect_silent(nms <- posterior_names(pdb_test))
  checkmate::expect_choice("eight_schools-eight_schools_centered", nms)
  expect_silent(nms <- data_names(pdb = pdb_test))
  checkmate::expect_choice("eight_schools", nms)
  expect_silent(nms <- model_names(pdb_test))
  checkmate::expect_choice("eight_schools_centered", nms)
  expect_silent(nms <- reference_posterior_names(pdb_test, "draws"))
  checkmate::expect_choice("eight_schools-eight_schools_noncentered", nms)


  expect_silent(pdb_github_test <- pdb_github("MansMeg/posteriordb/posterior_database"))
  posteriordb:::pdb_clear_cache(pdb_github_test)
  expect_silent(nms <- posterior_names(pdb_github_test))
  checkmate::expect_choice("eight_schools-eight_schools_centered", nms)
  expect_silent(nms <- data_names(pdb = pdb_github_test))
  checkmate::expect_choice("eight_schools", nms)
  expect_silent(nms <- model_names(pdb_github_test))
  checkmate::expect_choice("eight_schools_centered", nms)
  expect_silent(nms <- reference_posterior_names(pdb_test, "draws"))
  checkmate::expect_choice("eight_schools-eight_schools_noncentered", nms)
  posteriordb:::pdb_clear_cache(pdb_github_test)
})


test_that("pdb_default is github", {
  skip_on_appveyor()
  skip_if(is.null(github_pat()))

  expect_silent(pdb_default_test <- pdb_default())
  expect_silent(pdb_github_test <- pdb_github("MansMeg/posteriordb/posterior_database"))
  expect_equal(pdb_default_test, pdb_github_test)
})
