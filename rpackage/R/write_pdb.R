#' Write objects to pdb
#'
#' @description a function to simplify writing to a local pdb.
#'
#' @param x an object to write to the pdb.
#' @param pdb the pdb to write to. Currently only a local pdb.
#' @param overwrite overwrite existing file?
#' @export
write_pdb <- function(x, pdb, overwrite = FALSE, ...){
  checkmate::assert_class(pdb, "pdb_local")
  UseMethod("write_pdb")
}

#' @rdname write_pdb
#' @export
write_pdb.pdb_gold_standard_info <- function(x, pdb, overwrite = FALSE, ...){
  class(x) <- c(class(x), "list")
  write_json_to_path(x, "gold_standards/info", pdb, zip = FALSE, info = TRUE, overwrite = overwrite)
}

#' @rdname write_pdb
#' @export
write_pdb.pdb_gold_standard_draws <- function(x, pdb, overwrite = FALSE, ...){
  write_json_to_path(x, "gold_standards/draws", pdb, zip = TRUE, info = FALSE, overwrite = overwrite)
}
