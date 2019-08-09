context("test-pdb-content")

test_that("Check that all posteriors can access stan_data and stan_code", {
  expect_silent(pdb_dir <- pdb:::get_pdb_dir(getwd()))
  expect_silent(pdb_test <- pdb(x = pdb_dir))
  expect_silent(posteriors <- posterior_names(pdb_test))  
  
  for(i in seq_along(posteriors)){
    expect_silent(po <- posterior(posteriors[i], pdb_test))
    expect_silent(sc <- stan_code(po))
    expect_silent(sd <- stan_data(po))
  }
})

