#' Get all existing data names from a posterior database
#' 
#' @param pdbo a \code{pdb} object.
#' @export
data_names <- function(pdbo){
  checkmate::assert_class(pdbo, "pdb")
  pns <- dir(file.path(pdbo$path, "content", "data"), recursive = TRUE, full.names = FALSE)
  pns <- pns[grepl(pns, pattern = "\\.json\\.zip$")]
  endpoint(remove_file_extension(pns))
}

