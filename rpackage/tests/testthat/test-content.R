context("test-pdb-content")

test_that("Check that all posteriors can access stan_data and stan_code", {

  on_travis <- identical(Sys.getenv("TRAVIS"), "true")
  pdb_path <- getwd()
  if (on_travis) pdb_path <- Sys.getenv("TRAVIS_BUILD_DIR")
  posterior_db_path <- posteriordb:::get_pdb_dir(pdb_path)

  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(posteriors <- posterior_names(pdb_test))

  for (i in seq_along(posteriors)) {
    expect_silent(po <- posterior(name = posteriors[i], pdb = pdb_test))
    expect_silent(sc <- stan_code(po))
    expect_silent(sd <- stan_data(po))
  }
})




test_that("Check that all posteriors names in JSON is the same as file names", {
  skip("Check that all posteriors names in JSON is the same as file names")

  #expect_silent(pdb_dir <- posteriordb:::get_pdb_dir(getwd()))
  #expect_silent(pdb_test <- pdb(x = pdb_dir))
  #expect_silent(posteriors <- posterior_names(pdb_test))

  #stop("TODO")
  #for(i in seq_along(posteriors)){
  #  expect_silent(po <- posterior(posteriors[i], pdb_test))
  #}
})
