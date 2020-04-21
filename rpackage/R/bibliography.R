#' Get the bibliography of a posterior database
#'
#' @param pdb a posterior database connection
#' @param ... further arguments passed to [bibtex::read.bib]
#'
#' @export
bibliography <- function(pdb, ...){
  checkmate::assert_class(pdb, "pdb")
  fp <- file.path("bibliography/references.bib")
  pfn <- pdb_cached_local_file_path(pdb, path = fp)
  bibtex::read.bib(pfn, ...)
}

#' @rdname bibliography
#' @export
pdb_bibliography <- bibliography
