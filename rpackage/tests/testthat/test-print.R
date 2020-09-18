context("test-print")

test_that("All PPFs are printed", {
  skip_on_appveyor()
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(po <- posterior("eight_schools-eight_schools_noncentered", pdb = pdb_test))

  expect_output(print(model_info(po)), "stan")

})
