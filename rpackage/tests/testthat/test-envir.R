context("test-envir-travis")

test_that("Environmental variable POSTERIOR_DB_PATH exist at Travis", {
  on_travis <- identical(Sys.getenv("TRAVIS"), "true")
  if(on_travis){
    expect_failure(expect_equal(Sys.getenv("POSTERIOR_DB_PATH"), expected = ""))
  } else {
    expect_true(TRUE) # To give a nice test pass
  }
})

