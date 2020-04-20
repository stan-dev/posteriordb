context("test-alias")

test_that("posteriordb:::check_pdb indicates that github PDB is ok", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(po1 <- posterior(x = "8schools", pdb_test))
  expect_silent(po2 <- posterior(x = "8_schools", pdb_test))
  expect_silent(po3 <- posterior(x = "eight_schools", pdb_test))

  expect_identical(po1, po2)

  expect_silent(pn <- posterior_names(pdb_test))
  expect_silent(an <- alias_names(type = "posteriors", pdb_test))

  expect_failure(checkmate::expect_choice("8schools", pn))
  expect_success(checkmate::expect_choice("8schools", an))

})
