#' Write objects to pdb
#'
#' @description a function to simplify writing to a local pdb.
#'
#' @param x an object to write to the pdb.
#' @param pdb the pdb to write to. Currently only a local pdb.
#' @param ... further arguments supplied to methods.
#' @param overwrite overwrite existing file?
#' @export
write_pdb <- function(x, pdb, overwrite = FALSE, ...){
  checkmate::assert_class(pdb, "pdb_local")
  UseMethod("write_pdb")
}

#' @rdname write_pdb
#' @export
write_pdb.pdb_gold_standard_info <- function(x, pdb, overwrite = FALSE, ...){
  assert_gold_standard_info(x)
  class(x) <- c(class(x), "list")
  write_json_to_path(x, "gold_standards/info", pdb, zip = FALSE, info = TRUE, overwrite = overwrite)
}

#' @rdname write_pdb
#' @export
write_pdb.pdb_gold_standard_draws <- function(x, pdb, overwrite = FALSE, ...){
  assert_gold_standard_draws(x)
  write_json_to_path(x, "gold_standards/draws", pdb, zip = TRUE, info = FALSE, overwrite = overwrite)
}

#' @rdname write_pdb
#' @export
write_pdb.pdb_data <- function(x, pdb, name, overwrite = FALSE, ...){
  assert_data(x)
  write_json_to_path(x, "data/data", pdb, name = name, zip = TRUE, info = FALSE, overwrite = overwrite)
}

#' @rdname write_pdb
#' @export
write_pdb.pdb_data_info <- function(x, pdb,  overwrite = FALSE, ...){
  assert_data_info(x)
  class(x) <- c(class(x), "list")
  write_json_to_path(x, "data/info", pdb, zip = FALSE, info = TRUE, overwrite = overwrite)
}

#' @rdname write_pdb
#' @export
write_pdb.stanmodel <- function(x, pdb, overwrite = FALSE, ...){
  write_stan_to_path(x = x@model_code, "models/stan", pdb, name = x@model_name, zip = FALSE, info = FALSE, overwrite = overwrite)
}

#' @rdname write_pdb
#' @export
write_pdb.pdb_model_info <- function(x, pdb,  overwrite = FALSE, ...){
  assert_model_info(x)
  class(x) <- c(class(x), "list")
  write_json_to_path(x, "models/info", pdb, zip = FALSE, info = TRUE, overwrite = overwrite)
}

#' @rdname write_pdb
#' @export
write_pdb.pdb_posterior <- function(x, pdb,  overwrite = FALSE, ...){
  assert_pdb_posterior(x)
  x$pdb <- NULL
  x$model_info <- NULL
  x$data_info <- NULL
  class(x) <- c(class(x), "list")
  write_json_to_path(x, "posteriors", pdb, zip = FALSE, info = FALSE, overwrite = overwrite)
}
