context("test-pdb-gold_standard")

test_that("Check that gold_standard works as expected", {
  
  # To handle covr::codecov, that test package in temp folder
  on_travis <- identical(Sys.getenv("TRAVIS"), "true")
  pdb_path <- getwd()
  if (on_travis) pdb_path <- Sys.getenv("TRAVIS_BUILD_DIR")
  posterior_db_path <- posteriordb:::get_pdb_dir(pdb_path)
  
  expect_silent(pdb_test <- pdb(posterior_db_path))
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
