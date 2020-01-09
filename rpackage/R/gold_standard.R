#' Reference posterior information
#'
#' @details
#' Reference posterior information on how, when and by whom
#' the reference posterior was computed.
#'
#' @param x a \code{posterior} object to access the reference posterior for.
#' @param pdb a \code{pdb} posterior database connection.
#' @param ... Currently not used.
#'
#' @seealso reference_posterior_draws
#'
#' @export
reference_posterior_info <- function(x, pdb = pdb_default(), ...) {
  UseMethod("reference_posterior_info")
}

#' @rdname reference_posterior_info
#' @export
reference_posterior_info.pdb_posterior <- function(x, ...) {
  read_reference_posterior_info(x$reference_posterior_name, x$pdb)
}

#' @rdname reference_posterior_info
#' @export
reference_posterior_info.character <- function(x, pdb = pdb_default(), type = ...) {
  reference_posterior_info(posterior(x, pdb))
}


#' Read in reference_posterior_info json object
#' @param x a data, model or posterior name
#' @param pdb a posterior db object to access the info json from
#' @noRd
#' @keywords internal
read_reference_posterior_info <- function(x, pdb = NULL, type = "draws", ...) {
  if(is.null(x)) stop("There is currently no reference posterior for this posterior.")
  reference_posterior_info <- read_info_json(x, path = paste0("reference_posterior/", type), pdb = pdb, ...)
  class(reference_posterior_info) <- "pdb_reference_posterior_info"
  assert_reference_posterior_info(reference_posterior_info)
  reference_posterior_info
}



#' Read reference_posterior_draws json object
#' @param x a data, model or posterior name
#' @param pdb a posterior db object to access the info json from
#' @param ... further arguments. Currently not used.
#' @noRd
#' @keywords internal
read_reference_posterior_draws <- function(x, pdb, ...) {
  checkmate::assert_string(x, null.ok = TRUE)
  if(is.null(x)) stop("There is currently no reference posterior for this posterior.", call. = FALSE)
  checkmate::assert_class(pdb, classes = "pdb")

  rpfp <- pdb_cached_local_file_path(pdb, file.path("reference_posteriors", "draws", paste0(x, ".json")), unzip = TRUE)
  rpd <- jsonlite::read_json(rpfp, simplifyVector = TRUE)
  rpd$draws <- posterior::as_draws(rpd$draws)
  rpd$info <- reference_posterior_draws_info(x, pdb)
  class(rpd) <- c("pdb_reference_posterior_draws", class(rpd))
  assert_reference_posterior_draws(rpd)
  rpd
}

#' Extract data for posterior
#'
#' @inheritParams model_code_file_path
#' @export
reference_posterior_draws_file_path <- function(x, ...) {
  UseMethod("reference_posterior_draws_file_path")
}

#' @rdname reference_posterior_draws_file_path
#' @export
reference_posterior_draws_file_path.pdb_posterior <- function(x, ...) {
  if(is.null(x$reference_posterior_name)) stop2("There is currently no gold standard for this posterior.")
  reference_posterior_draws_file_path(x$reference_posterior_name, pdb = x$pdb)
}

#' @rdname reference_posterior_draws_file_path
#' @export
reference_posterior_draws_file_path.character <- function(x, pdb = pdb_default(), ...) {
  checkmate::assert_string(x)
  fp <- paste0("reference_posteriors/draws/", x, ".json")
  rpfp <- pdb_cached_local_file_path(pdb, path = fp, unzip = TRUE)
  checkmate::assert_file_exists(rpfp)
  rpfp
}

#' @rdname reference_posterior_draws_file_path
#' @export
reference_posterior_draws_file_path.pdb_reference_posterior_info <- function(x, pdb = pdb_default(), ...) {
  reference_posterior_draws_file_path(x$name, pdb, ...)
}

#' Reference Posterior posterior draws
#' @param x a [posterior] object or a posterior name.
#' @param pdb a [pdb] object (if [x] is a posterior name)
#' @param ... further arguments supplied to specific methods.
#' @return a reference posterior, draws_list object.
#' @export
reference_posterior_draws <- function(x, ...){
  UseMethod("reference_posterior_draws")
}

#' @rdname reference_posterior_draws
#' @export
reference_posterior_draws.character <- function(x, pdb = pdb_default(), ...){
  reference_posterior_draws(posterior(x, pdb = pdb))
}

#' @rdname reference_posterior_draws
#' @export
reference_posterior_draws.pdb_posterior <- function(x, ...){
  read_reference_posterior_draws(x = x$reference_posterior_name, pdb = x$pdb)
}

#' @rdname reference_posterior_draws
#' @export
reference_posterior_draws.pdb_reference_posterior_info <- function(x, pdb = pdb_default(), ...){
  read_reference_posterior_draws(x = x$name, pdb = pdb)
}

#' @rdname reference_posterior_draws
#' @export
assert_reference_posterior_draws <- function(x){
  checkmate::assert_class(x, c("pdb_reference_posterior_draws"))

  checkmate::assert_names(names(x), subset.of = c("name", "draws"))

  checkmate::assert_string(x$name)
  checkmate::assert_class(x$draws, c("draws_list"))
  checkmate::assert_class(x$info, c("pdb_reference_posterior_info"))

  # Assert named chains has the same parameter names
  par_names <- lapply(x$draws, names)
  for(i in seq_along(par_names)){
    checkmate::assert_true(identical(par_names[[1]],par_names[[i]]))
  }
}

#' Assert a [pdb_reference_posterior_info] object
#' @param x a an object to assert is a [pdb_reference_posterior_info] object.
#' @keywords internal
assert_reference_posterior_info <- function(x){
  checkmate::assert_class(x, "pdb_reference_posterior_info")
  checkmate::assert_names(names(x), identical.to = c("name", "inference", "diagnostics", "added_by", "added_date", "versions"))
  checkmate::assert_string(x$name)

  checkmate::assert_true(x$inference$method %in% c("stan_sampling", "analytical"))
  checkmate::assert_list(x$inference$method_arguments)

  if(!is.null(x$diagnostics)){
    checkmate::assert_names(names(x$diagnostics),
                            subset.of = c("effective_sample_size_bulk",
                                          "effective_sample_size_tail",
                                          "r_hat",
                                          "divergent_transitions",
                                          "effective_sample_size_bulk_per_iteration",
                                          "effective_sample_size_tail_per_iteration",
                                          "expected_fraction_of_missing_information"))
  }

  checkmate::assert_string(x$added_by)
  checkmate::assert_date(x$added_date)
  checkmate::assert_names(names(x$versions), subset.of = c("rstan_version", "r_Makevars", "r_version", "r_session"))
  if(!is.null(x$versions$rstan_version)){
    checkmate::assert_names(names(x$versions), must.include = c("rstan_version", "r_Makevars", "r_version", "r_session"))
  }
  for(i in seq_along(x$versions)){
    checkmate::assert_string(x$versions[[i]])
  }
}


#' Subset a [pdb_reference_posterior_draws] object
#' @param x a [pdb_reference_posterior_draws] to subest
#' @param variable Parameters to subset.
#' @param ... Further arguments (not used).
#' @export
subset.pdb_reference_posterior_draws <- function(x, variable, ...){
  requireNamespace("posterior")
  parameters <- paste0("^", variable, "(\\[[0-9]+\\])?$")
  x$draws <- subset(x$draws, variable = parameters, regex = TRUE)
  x
}


#' @export
print.pdb_reference_posterior_draws <- function(x, ...) {
  cat0("Reference Posterior: ", x$name, "\n")
  cat0("  Total draws: ", posterior::nchains(x$draws))
  cat0("  Dimensions: ", posterior::nvariables(x$draws))
}

#' @export
summary.pdb_reference_posterior_draws <- function(object, ...) {
  cat0("Reference Posterior: ", object$name, "\n")
  print(posterior::summarise_draws(object$draws))
}


#' @export
print.pdb_reference_posterior_info <- function(x, ...) {
  cat0("Posterior: ", x$name, "\n")
  cat0("Method: ", x$inference$method, " (", x$versions[[1]], ")\n")
  cat0("Arguments:\n")
  print_list(x$inference$method_arguments)
}
