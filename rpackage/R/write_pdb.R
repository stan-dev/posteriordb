#' Write objects to pdb
#'
#' @description a function to simplify writing to a local pdb.
#'
#' @param x an object to write to the pdb.
#' @param pdb the pdb to write to. Currently only a local pdb.
#' @param overwrite overwrite existing file?
#' @param type supported reference posterior types.
#' @param ... further arguments supplied to methods.
#' @export
write_pdb <- function(x, pdb, overwrite = FALSE, ...){
  checkmate::assert_class(pdb, "pdb_local")
  UseMethod("write_pdb")
}

#' @rdname write_pdb
#' @export
write_pdb.pdb_reference_posterior_info <- function(x, pdb, overwrite = FALSE, type, ...){
  checkmate::assert_choice(type, choices = supported_reference_posterior_types())
  assert_reference_posterior_info(x)
  class(x) <- c(class(x), "list")
  type_path <- type
  if(type %in% supported_summary_statistic_types()) type_path <- paste("summary_statistics", type, sep = "/")
  write_json_to_path(x, paste("reference_posteriors", type_path, "info", sep = "/"), pdb, zip = FALSE, info = TRUE, overwrite = overwrite)
}

#' @rdname write_pdb
#' @export
write_pdb.pdb_reference_posterior_draws <- function(x, pdb, overwrite = FALSE, ...){
  assert_reference_posterior_draws(x)
  assert_checked_reference_posterior_draws(x)
  write_pdb(info(x), pdb = pdb, overwrite = overwrite, type = "draws")
  write_json_to_path(x, "reference_posteriors/draws/draws", pdb, zip = TRUE, info = FALSE, overwrite = overwrite)
}

#' @rdname write_pdb
#' @export
write_pdb.pdb_reference_posterior_summary_statistic <- function(x, pdb, overwrite = FALSE, ...){
  assert_reference_posterior_summary_statistic(x)
  assert_checked_summary_statistics_draws(x)
  sstype <- summary_statistic_type(x)
  write_pdb(info(x), pdb = pdb, overwrite = overwrite, type = sstype)
  write_json_to_path(x, path = paste0("reference_posteriors/summary_statistics/", sstype, "/", sstype), pdb, zip = FALSE, info = FALSE, overwrite = overwrite, name = info(x)$name)
}


#' @rdname write_pdb
#' @export
write_pdb.pdb_data <- function(x, pdb, overwrite = FALSE, ...){
  assert_data(x)
  write_pdb(info(x), pdb = pdb, overwrite = overwrite)
  write_json_to_path(x, "data/data", pdb, name = info(x)$name, zip = TRUE, info = FALSE, overwrite = overwrite)
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
write_pdb.pdb_model_code <- function(x, pdb,  overwrite = FALSE, ...){
  assert_model_code(x)
  write_pdb(info(x), pdb, overwrite = overwrite)
  write_model_code_to_path(x, path = "models/", pdb = pdb, name = info(x)$name, framework = framework(x), zip = FALSE, info = FALSE, overwrite = overwrite)
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
  pdb(x) <- NULL
  x$model_info <- NULL
  x$data_info <- NULL
  class(x) <- c(class(x), "list")
  write_json_to_path(x, "posteriors", pdb, zip = FALSE, info = FALSE, overwrite = overwrite)
}
