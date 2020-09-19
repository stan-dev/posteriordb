# Test utils - only used for tests


#' Get path to the posterior database
#' @noRd
get_test_pdb_dir <- function(x) {
  x <- getwd()
  # If on Travis - use Travis build path
  # To handle covr::codecov, that test package in temp folder
  if (on_travis()) x <- Sys.getenv("TRAVIS_BUILD_DIR")
  # If on Appveyor - use Appveyor build path
  if (on_appveyor()) x <- Sys.getenv("APPVEYOR_BUILD_FOLDER")
  find_local_posterior_database(x)
}


find_local_posterior_database <- function(x){
  checkmate::assert_directory(x)
  fp <- normalizePath(x)
  while (!"posterior_database" %in% dir(fp) & basename(fp) != "") {
    fp <- dirname(fp)
  }
  if (basename(fp) == "") {
    stop2("No local posterior database in path '", x, "'.")
  }
  fpep <- file.path(fp, "posterior_database")
  pdb <- pdb_local(fpep)
  if(is_pdb_endpoint(pdb)){
    return(fpep)
  } else {
    stop2("No local posterior database in path '", fpep, "'.")
  }
}

on_travis <- function() identical(Sys.getenv("TRAVIS"), "true")
on_appveyor <- function() identical(Sys.getenv("APPVEYOR"), "true")
