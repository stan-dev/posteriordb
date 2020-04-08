#' Extract information from a pdb object
#'
#' @param x a [pdb_data], [pdb_model_code] and [pdb_reference_posterior]
#' @param info a [pdb_]
#'
#' @export
info <- function(x) {
  attr(x, "info")
}

#' Set information to a pdb object
#'
#' @inheritParams info
#' @param value an info object
#'
`info<-` <- function(x, value){
  attr(x, "info") <- value
  x
}
