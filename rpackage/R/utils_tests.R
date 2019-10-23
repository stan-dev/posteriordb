# Test utils - only used for tests


#' Get path to the posterior database
#' @noRd
get_test_pdb_dir <- function(x) {

  # If on Travis - use Travis build path
  # To handle covr::codecov, that test package in temp folder
  on_travis <- identical(Sys.getenv("TRAVIS"), "true")
  x <- getwd()
  if (on_travis) x <- Sys.getenv("TRAVIS_BUILD_DIR")

  pdb_dir_entrypoint(x)
}
