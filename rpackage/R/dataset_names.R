#' Get all existing dataset names from a posterior database
#' 
#' @param pdbo a \code{pdb} object.
#' @export
dataset_names <- function(pdbo){
  checkmate::assert_class(pdbo, "pdb")
  pns <- dir(file.path(pdbo$path, "content", "dataset"), recursive = TRUE, full.names = FALSE)
  pns <- pns[grepl(pns, pattern = "\\.json\\.zip$")]
  basename(remove_file_extension(pns))
}

