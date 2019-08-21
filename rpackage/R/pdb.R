#' Posterior database (pdb) constructor
#'
#' @param x a path to the posterior database
#' (i.e. where folders content and posteriors exists)
#'
#' @return a \code{pdb} object
#'
#' @export
pdb <- function(x = getwd()){
  assert_pdb_dir(x)
  pdbo <- list(path = x)
  class(pdbo) <- c("pdb", "list")
  pdbo
}

is.pdb_dir <- function(x){
  checkmate::assert_directory_exists(x)
  all(c("content", "posteriors") %in% dir(x))
}

assert_pdb_dir <- function(x){
  if(!is.pdb_dir(x)) stop("'", x, "' is not a path to a posterior database.")
}