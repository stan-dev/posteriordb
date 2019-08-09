#' Get all existing model names from a posterior database
#' 
#' @param pdbo a \code{pdb} object.
#' @export
model_names <- function(pdbo){
  checkmate::assert_class(pdbo, "pdb")
  pns <- dir(file.path(pdbo$path, "content", "models"), recursive = TRUE, full.names = FALSE)
  pns <- pns[grepl(pns, pattern = "\\.json$")]
  basename(remove_file_extension(pns))
}

