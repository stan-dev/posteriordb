#' Extract information
#'
#' @param x a [pdb_data], [pdb_model_code] and [pdb_reference_posterior]
#'
#' @export
info <- function(x) {
  attr(x, "info")
}

#' @rdname info
`info<-` <- function(x, value){
  attr(x, "info") <- value
  x
}
