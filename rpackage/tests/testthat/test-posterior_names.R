context("test-posterior_names")

test_that("posterior_names handels list of objects", {

  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(pns <- posterior_names(pdb_test, pdb_test))
  expect_silent(pns_list <- posterior_names(list(pdb_test, pdb_test)))
  expect_equal(pns_list[[1]], pns)

})
