context("test-posterior-getters")

test_that("Check that all posteriors can access stan_data and stan_code", {

  # To handle covr::codecov, that test package in temp folder
  on_travis <- identical(Sys.getenv("TRAVIS"), "true")
  pdb_path <- getwd()
  if (on_travis) pdb_path <- Sys.getenv("TRAVIS_BUILD_DIR")
  posterior_db_path <- posteriordb:::get_pdb_dir(pdb_path)

  expect_silent(pdb_test <- pdb(posterior_db_path))

  expect_silent(po <- posterior("8_schools-8_schools_noncentered", pdb = pdb_test))
  
  # Test stan_data_file_path
  expect_silent(sdfp <- stan_data_file_path(po))
  expect_true(file.exists(sdfp))
  expect_true(grepl(pattern = tempdir(), x = sdfp))
  expect_equal(posteriordb:::get_file_extension(sdfp), "json")
  expect_silent(jsonlite::read_json(sdfp))
  
  # Test data_info
  expect_silent(di <- data_info(po))
  expect_s3_class(di, "pdb_data_info")
  expect_output(print(di), "Data: 8_schools")
  
  # Test model_code
  expect_silent(mcfp <- model_code_file_path(po, "stan"))
  expect_true(file.exists(mcfp))
  expect_true(grepl(pattern = tempdir(), x = mcfp))
  expect_equal(posteriordb:::get_file_extension(mcfp), "stan")

  # Test model_code
  expect_silent(mc <- model_code(po, framework = "stan"))
  expect_s3_class(mc, "pdb_model_code")
  expect_output(print(mc), "data \\{")
  expect_output(print(mc), "parameters \\{")
  expect_output(print(mc), "model \\{")
  
  # Test model_info
  expect_silent(mi <- model_info(po))
  expect_s3_class(mi, "pdb_model_info")
  expect_output(print(mi), "Model: 8_schools_noncentered")
  
  expect_output(print(po), "Posterior")

  skip("Get posteriors draws directly from po object")
  # Get posteriors draws directly
  expect_silent(pd <- posterior_draws(po))
  
})


