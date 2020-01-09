context("test-pdb-content")

test_that("posteriordb:::check_pdb indicates that local PDB content is ok", {
  skip("Fix posterior references")
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  posteriordb:::pdb_clear_cache(pdb_test)
  expect_message(posteriordb::: check_pdb(pdb = pdb_test), "Posterior database is ok")
  expect_message(posteriordb:::check_pdb(pdb = pdb_test), "Posterior database is ok")
  expect_output(print(pdb_test), "Posterior Database")
  expect_output(print(pdb_test), "local")
  posteriordb:::pdb_clear_cache(pdb_test)
})
