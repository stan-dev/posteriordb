context("test-pdb-reference_posterior")

test_that("Check that reference_posterior works as expected", {

  posterior_db_path <- posteriordb:::get_test_pdb_dir()

  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(po <- posterior("eight_schools-eight_schools_centered", pdb_test))
  expect_silent(gsi1 <- reference_posterior_info(po, type = "draws"))
  expect_s3_class(gsi1, "pdb_reference_posterior_info")
  expect_silent(po <- posterior("eight_schools-eight_schools_noncentered", pdb_test))
  expect_silent(gsi2 <- reference_posterior_draws_info(po))
  expect_s3_class(gsi2, "pdb_reference_posterior_info")
  expect_identical(gsi1, gsi2)
  expect_silent(gsi3 <- reference_posterior_draws_info("eight_schools-eight_schools_centered", pdb_test))
  expect_s3_class(gsi3, "pdb_reference_posterior_info")
  expect_identical(gsi1, gsi3)

  expect_output(print(gsi1), "Posterior: eight_schools-eight_schools_noncentered")
  expect_output(print(gsi1), "Method: stan_sampling ")
  expect_output(print(gsi1), "Arguments:")


  expect_silent(po <- posterior("eight_schools-eight_schools_centered", pdb_test))
  expect_silent(pd1 <- reference_posterior_draws(x = po))
  expect_s3_class(pd1, "pdb_reference_posterior_draws")
  expect_s3_class(pd1, "draws_list")
  expect_silent(po <- posterior("eight_schools-eight_schools_noncentered", pdb_test))
  expect_silent(pd2 <- reference_posterior_draws(x = po))
  expect_identical(pd1, pd2)
  expect_silent(pd3 <- reference_posterior_draws("eight_schools-eight_schools_centered", pdb_test))
  expect_s3_class(pd3, "pdb_reference_posterior_draws")
  expect_identical(pd1, pd3)

  expect_silent(gsdfp <- reference_posterior_draws_file_path(po))
  expect_true(file.exists(gsdfp))

  expect_output(print(pd1), "Posterior: eight_schools-eight_schools_noncentered")

  expect_output(sf <- summary(pd1), "Posterior: eight_schools-eight_schools_noncentered")
  expect_output(st1 <- summary(subset(pd1, "theta[1]")), "Posterior: eight_schools-eight_schools_noncentered")
  expect_failure(expect_equal(sf, st1))

  expect_silent(po <- posterior("prideprejustice_chapter-ldaK5", pdb_test))
  expect_error(gs <- reference_posterior_draws(po),
               regexp = "There is currently no reference posterior for this posterior.")
  expect_error(gs <- reference_posterior_draws(po),
               regexp = "There is currently no reference posterior for this posterior.")
})
