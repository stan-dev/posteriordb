context("test-pdb-reference_posterior_summary_statistics")

test_that("Check that reference_posterior_summary_statistics work as expected", {

  posterior_db_path <- posteriordb:::get_test_pdb_dir()

  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(po <- posterior("eight_schools-eight_schools_noncentered", pdb_test))
  expect_silent(rpssi1 <- reference_posterior_info(po, type = "mean"))
  expect_s3_class(rpssi1, "pdb_reference_posterior_info")
  expect_silent(rpssi3 <- reference_posterior_info("eight_schools-eight_schools_noncentered", pdb_test, type = "mean"))
  expect_identical(rpssi1, rpssi3)

  expect_output(print(rpssi1), "Posterior: eight_schools-eight_schools_noncentered")

  expect_silent(rpm1 <- reference_posterior_summary_statistic(x = po, type = "mean"))
  expect_silent(rpm2 <- reference_posterior_summary_statistics(x = po))
  expect_identical(rpm1, rpm2$mean)

  expect_output(print(rpm1), "Posterior: eight_schools-eight_schools_noncentered")

  expect_silent(po <- posterior("prideprejustice_chapter-ldaK5", pdb_test))
  expect_error(rpm <- reference_posterior_summary_statistic(po, type = "mean"),
               regexp = "There is currently no reference posterior for this posterior.")
})



test_that("compute and write summary_statistics", {
  if(on_github_actions()) skip_on_os("windows")

  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(po <- posterior("eight_schools-eight_schools_noncentered", pdb_test))
  expect_silent(rpd <- reference_posterior_draws(po))

  expect_silent(rpdc <- check_summary_statistics_draws(x = rpd))
  expect_silent(rpm <- compute_reference_posterior_summary_statistic(rpdc, "mean"))
  expect_silent(rpmi <- info(rpm))

  # Setup posterior
  # This is needed to access the created reference posterior
  # since it uses posterior() to access the test reference posterior
  po$name <- "test_data-test_model"
  po$reference_posterior_name <- po$name
  write_pdb(po, pdb_test)

  # Test write gsd
  info(rpm)$name <- "test_data-test_model"
  expect_silent(write_pdb(rpm, pdb_test))
  expect_error(write_pdb(rpm, pdb_test))
  expect_silent(write_pdb(rpm, pdb_test, overwrite = TRUE))

  expect_silent(rpt <- pdb_reference_posterior_summary_statistics(x = "test_data-test_model", pdb = pdb_test))
  expect_equal(rpt$mean, rpm, tolerance = 0.000000000000001)
  expect_identical(info(rpm), info(rpt$mean))
  expect_identical(rpm$names, rpt$mean$names)

  # Remove rpd
  expect_silent(remove_pdb(rpt$mean, pdb = pdb_test))
  pdb_clear_cache(pdb_test)
  expect_error(pdb_reference_posterior_draws("test_data-test_model", pdb_test))

  # Cleanup
  remove_pdb(po, pdb_test)
})
