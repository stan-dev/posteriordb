context("test-pdb")

test_that("posteriordb:::check_pdb indicates that local PDB is ok", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  posteriordb:::pdb_clear_cache(pdb_test)
  expect_message(posteriordb:::check_pdb(pdb = pdb_test), "Posterior database is ok")
  expect_message(posteriordb:::check_pdb(pdb = pdb_test), "Posterior database is ok")
  expect_output(print(pdb_test), "Posterior Database")
  expect_output(print(pdb_test), "local")
})

test_that("model_names and data_names works as expected", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(posteriors <- posterior_names(pdb_test))
  expect_silent(mn <- model_names(pdb_test))
  expect_silent(dn <- data_names(pdb_test))

  slpdat <- unlist(lapply(strsplit(posteriors, split = "-"), FUN = function(x) x[[1]]))
  slpmn <- unlist(lapply(strsplit(posteriors, split = "-"), FUN = function(x) x[[2]]))

  expect_true(all(slpmn %in% mn))
  expect_true(all(slpdat %in% dn))
})


test_that("posteriordb:::check_pdb indicates that github PDB is ok", {
  expect_silent(pdb_github_test <- pdb_github("MansMeg/posteriordb/posterior_database"))
  expect_output(print(pdb_github_test), "Posterior Database")
  expect_output(print(pdb_github_test), "github")
  posteriordb:::pdb_clear_cache(pdb_github_test)
  expect_message(posteriordb:::check_pdb(pdb = pdb_github_test, posterior_idx = 1:2), "Posterior database is ok")
  expect_message(posteriordb:::check_pdb(pdb = pdb_github_test, posterior_idx = 1:2), "Posterior database is ok")
})
