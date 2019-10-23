context("test-pdb")

test_that("posteriordb:::check_pdb indicates that PDB is ok", {

  # To handle covr::codecov, that test package in temp folder
  on_travis <- identical(Sys.getenv("TRAVIS"), "true")
  pdb_path <- getwd()
  if (on_travis) pdb_path <- Sys.getenv("TRAVIS_BUILD_DIR")
  posterior_db_path <- posteriordb:::get_pdb_dir(pdb_path)

  expect_silent(pdb_test <- pdb(posterior_db_path))

  expect_message(posteriordb:::check_pdb(pdb = pdb_test), "Posterior database is ok")
  
  expect_output(print(pdb_test), "Posterior Database")
})

test_that("model_names and data_names works as expected", {
  
  # To handle covr::codecov, that test package in temp folder
  on_travis <- identical(Sys.getenv("TRAVIS"), "true")
  pdb_path <- getwd()
  if (on_travis) pdb_path <- Sys.getenv("TRAVIS_BUILD_DIR")
  posterior_db_path <- posteriordb:::get_pdb_dir(pdb_path)
  
  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(posteriors <- posterior_names(pdb_test))
  expect_silent(mn <- model_names(pdb_test))
  expect_silent(dn <- data_names(pdb_test))
  
  slpdat <- unlist(lapply(strsplit(posteriors, split = "-"), FUN = function(x) x[[1]]))
  slpmn <- unlist(lapply(strsplit(posteriors, split = "-"), FUN = function(x) x[[2]]))
  
  expect_true(all(slpmn %in% mn))
  expect_true(all(slpdat %in% dn))
})
