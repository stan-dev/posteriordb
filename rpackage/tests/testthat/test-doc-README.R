context("test-README.md")

test_that("README.md works as stated", {
  skip_on_cran()
  skip_on_appveyor()
  on_travis <- identical(Sys.getenv("TRAVIS"), "true")
  TRAVIS_BUILD_DIR <- Sys.getenv("TRAVIS_BUILD_DIR")
  if(on_travis){
    # On Travis the package are checked in rpackage/
    fp_to_README_md <- file.path(TRAVIS_BUILD_DIR, "README.md")
  } else {
    fp_to_README_md <- "../../../README.md"
  }

  skip_if(!file.exists(fp_to_README_md))
  # check hash
  # If this fails, the CONTRIBUTING.md has been changed.
  # Please check that no code has been changed or update this test suite accordingly
  # Then change the hash to the md5 of the new updated file.
  md5_hash <- digest::digest(readLines(fp_to_README_md), algo = "md5")
  expect_equal(md5_hash, "b3d18584e9bdc3a40b1f276d851e38e8")

  skip_if(is.null(github_pat()))

  expect_silent(pd <- pdb_default())
  expect_silent(pn <- posterior_names(pd))

  head_pn <- c("arK-arK",
                "arma-arma11",
                "bball_drive_event_0-hmm_drive_0",
                "bball_drive_event_1-hmm_drive_1",
                "butterfly-multi_occupancy",
                "diamonds-diamonds")
  expect_equal(head(pn), head_pn)

  expect_silent(po <- pdb_posterior("eight_schools-eight_schools_centered", pdb = pd))
  expect_s3_class(po, "pdb_posterior")
  expect_output(print(po))

  expect_silent(sc <- pdb_stan_code(x = po))
  expect_s3_class(sc, "pdb_model_code")
  expect_output(print(sc))

  expect_silent(sci <- info(sc))
  expect_s3_class(sci, "pdb_model_info")
  expect_output(print(sci))

  expect_silent(dat <- pdb_data(po))
  expect_s3_class(dat, "pdb_data")
  expect_output(print(dat))

  expect_silent(di <- info(dat))
  expect_s3_class(di, "pdb_data_info")
  expect_output(print(di))

  expect_silent(rpd <- reference_posterior_draws(po))
  expect_s3_class(rpd, "pdb_reference_posterior_draws")
  expect_output(print(rpd))

  expect_silent(rpi <- info(rpd))
  expect_s3_class(rpi, "pdb_reference_posterior_info")
  expect_output(print(rpi))

  expect_silent(mi <- pdb_model_info(po))
  expect_s3_class(mi, "pdb_model_info")
  expect_silent(di <- pdb_data_info(po))
  expect_s3_class(di, "pdb_data_info")
  expect_silent(rpi <- pdb_reference_posterior_draws_info(po))
  expect_s3_class(rpi, "pdb_reference_posterior_info")

})
