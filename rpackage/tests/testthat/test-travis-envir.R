context("test-travis-envir")

test_that("Environmental variable TRAVIS_BUILD_DIR exist on Travis CI", {
  skip_on_os("windows")

  on_travis <- identical(Sys.getenv("TRAVIS"), "true")
  if(on_travis){
    expect_failure(expect_equal(Sys.getenv("TRAVIS_BUILD_DIR"), expected = ""))
  } else {
    expect_true(TRUE) # To give a nice test pass when run locally
  }
})
