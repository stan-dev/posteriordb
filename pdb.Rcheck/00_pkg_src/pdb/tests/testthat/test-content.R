context("test-pdb-content")

test_that("Check that all posteriors can access stan_data and stan_code", {
  test_dir <- getwd()
  setwd("../../../")
  root_dir <- getwd()
  setwd(test_dir)
  
  expect_silent(pdb_test <- pdb(root_dir))
  expect_silent(posteriors <- posterior_names(pdb_test))  
  
  for(i in seq_along(posteriors)){
    expect_silent(po <- posterior(posteriors[i], pdb_test))
    expect_silent(sc <- stan_code(po))
    expect_silent(sd <- stan_data(po))
  }
})

