context("test-pdb-gold_standard")

test_that("Check that gold_standard works as expected", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()

  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(po <- posterior("eight_schools-eight_schools_centered", pdb_test))
  expect_silent(gs <- gold_standard(po))
  expect_s3_class(gs, "pdb_posterior_fit")
  expect_silent(po <- posterior("eight_schools-eight_schools_noncentered", pdb_test))
  expect_silent(gs <- gold_standard(po))
  expect_s3_class(gs, "pdb_posterior_fit")
  expect_silent(pd <- posterior_draws(gs))
  expect_s3_class(pd, "data.frame")
  expect_silent(po <- posterior("prideprejustice_chapter-ldaK5", pdb_test))
  expect_error(gs <- gold_standard(po),
               regexp = "There is currently no gold standard for this posterior.")
})
