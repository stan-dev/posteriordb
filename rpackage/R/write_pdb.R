#' Write objects to pdb
#'
#' @description a function to simplify writing to a local pdb.
#'
#' @param x an object to write to the pdb.
#' @param pdb the pdb to write to. Currently only a local pdb.
#' @param overwrite overwrite existing file?
#' @param name the name of the data (used for [pdb_data] objects only).
#' @param ... further arguments supplied to methods.
#' @export
write_pdb <- function(x, pdb, overwrite = FALSE, ...){
  checkmate::assert_class(pdb, "pdb_local")
  UseMethod("write_pdb")
}

#' @rdname write_pdb
#' @export
write_pdb.pdb_reference_posterior_info <- function(x, pdb, overwrite = FALSE, type, ...){
  checkmate::assert_choice(type, choices = c("draws", "expectations"))
  assert_reference_posterior_info(x)
  class(x) <- c(class(x), "list")
  write_json_to_path(x, paste("reference_posteriors", type, "info", sep = "/"), pdb, zip = FALSE, info = TRUE, overwrite = overwrite)
}

#' @rdname write_pdb
#' @export
write_pdb.pdb_reference_posterior_draws <- function(x, pdb, overwrite = FALSE, ...){
  assert_reference_posterior_draws(x)
  write_pdb(info(x), pdb = pdb, overwrite = overwrite, type = "draws")
  write_json_to_path(x, "reference_posteriors/draws/draws", pdb, zip = TRUE, info = FALSE, overwrite = overwrite)
}

#' @rdname write_pdb
#' @export
write_pdb.pdb_data <- function(x, pdb, overwrite = FALSE, name, ...){
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
