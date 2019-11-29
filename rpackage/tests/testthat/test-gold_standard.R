context("test-pdb-gold_standard")

test_that("Check that gold_standard works as expected", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()

  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(po <- posterior("eight_schools-eight_schools_centered", pdb_test))
  expect_silent(gsi1 <- gold_standard_info(po))
  expect_s3_class(gsi1, "pdb_gold_standard_info")
  expect_silent(po <- posterior("eight_schools-eight_schools_noncentered", pdb_test))
  expect_silent(gsi2 <- gold_standard_info(po))
  expect_s3_class(gsi2, "pdb_gold_standard_info")
  expect_identical(gsi1, gsi2)
  expect_silent(gsi3 <- gold_standard_info("eight_schools-eight_schools_centered", pdb_test))
  expect_s3_class(gsi3, "pdb_gold_standard_info")
  expect_identical(gsi1, gsi3)

  expect_output(print(gsi1), "Posterior: eight_schools-eight_schools_noncentered")
  expect_output(print(gsi1), "Method: stan_sampling ")
  expect_output(print(gsi1), "Arguments:")


  expect_silent(po <- posterior("eight_schools-eight_schools_centered", pdb_test))
  expect_silent(pd1 <- gold_standard_draws(x = po))
  expect_s3_class(pd1, "pdb_gold_standard_draws")
  expect_s3_class(pd1$draws, "draws_list")
  expect_silent(po <- posterior("eight_schools-eight_schools_noncentered", pdb_test))
  expect_silent(pd2 <- gold_standard_draws(x = po))
  expect_identical(pd1, pd2)
  expect_silent(pd3 <- gold_standard_draws("eight_schools-eight_schools_centered", pdb_test))
  expect_s3_class(pd3, "pdb_gold_standard_draws")
  expect_identical(pd1, pd3)

  expect_output(print(pd1), "Posterior: eight_schools-eight_schools_noncentered")

  expect_silent(po <- posterior("prideprejustice_chapter-ldaK5", pdb_test))
  expect_error(gs <- gold_standard_info(po),
               regexp = "There is currently no gold standard for this posterior.")
  expect_error(gs <- gold_standard_draws(po),
               regexp = "There is currently no gold standard for this posterior.")
})
