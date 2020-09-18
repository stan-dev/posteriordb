context("test-filter-tibble")

test_that("Filter posteriors locally and on github", {
  skip_on_appveyor()

  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(po <- filter_posteriors(pdb = pdb_test, name == "eight_schools-eight_schools_noncentered"))
  expect_silent(tblp <- posteriors_tbl_df(pdb = pdb_test))

  skip_if(is.null(github_pat()))
  expect_silent(pdb_github_test <- pdb_github("MansMeg/posteriordb/posterior_database"))
  posteriordb:::pdb_clear_cache(pdb_github_test)
  expect_message(po <- filter_posteriors(pdb = pdb_github_test, name == "eight_schools-eight_schools_noncentered"))
  posteriordb:::pdb_clear_cache(pdb_github_test)
})
