context("test-check_posterior_draws")

test_that("test-check_posterior_draws", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))

  expect_silent(rp <- reference_posterior_draws(x = "eight_schools-eight_schools_noncentered", pdb_test))
  expect_silent(rp1 <- check_reference_posterior_draws(x = rp))
  expect_silent(rp2 <- check_reference_posterior_draws(x = "eight_schools-eight_schools_noncentered", pdb = pdb_test))
  po <- pdb_posterior("eight_schools-eight_schools_noncentered", pdb_test)
  expect_silent(rp3 <- check_reference_posterior_draws(x = po))

  expect_equal(rp1, rp2)
  expect_equal(rp1, rp3)
})

test_that("check_pdb_posterior works", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))

  po <- pdb_posterior("eight_schools-eight_schools_noncentered", pdb_test)

  if(on_github_actions()) skip_on_os("linux") # Currently problem with stringi on ubuntu (2021-03-10)
  expect_message(check_pdb_posterior(po, run_stan_code_checks = FALSE), regexp = "Posterior is ok.")
})
