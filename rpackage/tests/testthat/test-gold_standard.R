context("test-pdb-gold_standard")

test_that("Check that gold_standard works as expected", {
  expect_silent(pdb_dir <- posteriordb:::get_pdb_dir(getwd()))
  expect_silent(pdb_test <- pdb(pdb_dir))
  expect_silent(po <- posterior("8_schools-8_schools_centered", pdb_test))
  expect_silent(gs <- gold_standard(po))
  expect_s3_class(gs, "pdb_posterior_fit")
  expect_silent(po <- posterior("8_schools-8_schools_noncentered", pdb_test))
  expect_silent(gs <- gold_standard(po))
  expect_s3_class(gs, "pdb_posterior_fit")
  expect_silent(po <- posterior("prideprejustice_chapter-ldaK5", pdb_test))
  expect_error(gs <- gold_standard(po),
               regexp = "There is currently no gold standard for this posterior.")
})
