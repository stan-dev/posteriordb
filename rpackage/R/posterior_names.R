#' Get all existing posterior names from a posterior database
#'
#' @param pdbo a \code{pdb} object.
#' @export
posterior_names <- function(pdbo){
  checkmate::assert_class(pdbo, "pdb")
  pns <- dir(file.path(pdbo$path, "posteriors"))
  remove_file_extension(pns)
}

#' @export
names.pdb <- function(x){
  posterior_names(x)
}
