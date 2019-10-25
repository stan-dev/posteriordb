# Test utils - only used for tests


#' Get path to the posterior database
#' @noRd
get_test_pdb_dir <- function(x) {
  # If on Travis - use Travis build path
  # To handle covr::codecov, that test package in temp folder
  on_travis <- identical(Sys.getenv("TRAVIS"), "true")
  x <- getwd()
  if (on_travis) x <- Sys.getenv("TRAVIS_BUILD_DIR")
  find_local_posterior_database(x)
}


find_local_posterior_database <- function(x){
  checkmate::assert_directory(x)
  fp <- normalizePath(x)
  while (!"posterior_database" %in% dir(x) & basename(fp) != "") {
    fp <- dirname(fp)
  }
  if (basename(fp) == "") {
    stop2("No local posterior database in path '", x, "'.")
  }
  fpep <- file.path(fp, "posterior_database")
  if(is.pdb_local_entrypoint(fpep)){
    return(fpep)
  } else {
    stop2("No local posterior database in path '", fpep, "'.")
  }
}
