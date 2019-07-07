#' Posterior database (pdb) constructor
#' 
#' @param x a path to the posterior database 
#' (i.e. where folders content and posteriors exists)
#' 
#' @return a \code{pdb} object
#' 
#' @export
pdb <- function(x=getwd()){
  checkmate::assert_directory_exists(x)
  checkmate::assert_subset(c("posteriors", "content"), choices = dir(x))
  pdbo <- list(path = x)
  class(pdbo) <- c("pdb", "list")
  pdbo
}
