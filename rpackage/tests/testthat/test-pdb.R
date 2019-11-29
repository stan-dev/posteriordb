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

  posteriors <- posteriors[grepl(x = posteriors, "-")]
  slpdat <- unlist(lapply(strsplit(posteriors, split = "-"), FUN = function(x) x[[1]]))
  slpmn <- unlist(lapply(strsplit(posteriors, split = "-"), FUN = function(x) x[[2]]))

  expect_true(all(slpmn %in% mn))
  expect_true(all(slpdat %in% dn))
})


test_that("pdb_version", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  checkmate::expect_list(pdb_version(pdb_test))
  checkmate::expect_names(names(pdb_version(pdb_test)), must.include = "sha")
})
