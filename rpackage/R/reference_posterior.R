#' Reference posterior information
#'
#' @details
#' Reference posterior information on how, when and by whom
#' the reference posterior was computed.
#'
#' @param x a \code{posterior} object to access the reference posterior for.
#' @param pdb a \code{pdb} posterior database connection.
#' @param type Type of reference posterior [draws] or [summary_statistic].
#' @param ... Currently not used.
#'
#' @seealso reference_posterior_draws
#'
#' @export
reference_posterior_info <- function(x, type, pdb = pdb_default(), ...) {
  UseMethod("reference_posterior_info")
}

#' @rdname reference_posterior_info
#' @export
pdb_reference_posterior_info <- reference_posterior_info

#' @rdname reference_posterior_info
#' @export
reference_posterior_draws_info <- function(x, pdb = pdb_default(), ...) {
  reference_posterior_info(x, type = "draws", pdb = pdb)
}

#' @rdname reference_posterior_info
#' @export
pdb_reference_posterior_draws_info <- reference_posterior_draws_info


#' @rdname reference_posterior_info
#' @export
reference_posterior_info.pdb_posterior <- function(x, type, ...) {
  read_reference_posterior_info(x = x$reference_posterior_name, type = type, pdb = pdb(x))
}

#' @rdname reference_posterior_info
#' @export
reference_posterior_info.character <- function(x, type, pdb = pdb_default(), ...) {
  reference_posterior_info(x = posterior(x, pdb), type = type)
}

#' @rdname reference_posterior_info
#' @export
reference_posterior_info.list <- function(x, type = NULL, pdb = NULL, ...) {
  class(x) <- "pdb_reference_posterior_info"
  assert_reference_posterior_info(x)
  x
}


#' Read in reference_posterior_info json object
#' @param x a data, model or posterior name
#' @param pdb a posterior db object to access the info json from
#' @param type Type of reference posterior [draws] or sufficient statistic of interst, such as the means.
#' @noRd
#' @keywords internal
read_reference_posterior_info <- function(x, type, pdb = NULL, ...) {
  if(is.null(x)) stop("There is currently no reference posterior for this posterior.")
  type_path <- type
  if(type %in% supported_summary_statistic_types()) type_path <- paste("summary_statistics", type, sep = "/")
  reference_posterior_info <- read_info_json(x, path = paste0("reference_posteriors/", type_path, "/info"), pdb = pdb, ...)
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

  rpfp <- pdb_cached_local_file_path(pdb, file.path("reference_posteriors", "draws", "draws", paste0(x, ".json")), unzip = TRUE)
  rpd <- jsonlite::read_json(rpfp, simplifyVector = FALSE)
  rpd <- lapply(rpd, FUN = function(X) lapply(X, as.numeric))
  rpd <- posterior::as_draws_list(rpd)
  names(rpd) <- NULL
  info(rpd) <- reference_posterior_draws_info(x, pdb)
  pdb(rpd) <- pdb
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
  reference_posterior_draws_file_path(x$reference_posterior_name, pdb = pdb(x))
}

#' @rdname reference_posterior_draws_file_path
#' @export
reference_posterior_draws_file_path.character <- function(x, pdb = pdb_default(), ...) {
  checkmate::assert_string(x)
  fp <- paste0("reference_posteriors/draws/draws/", x, ".json")
  rpfp <- pdb_cached_local_file_path(pdb, path = fp, unzip = TRUE)
  checkmate::assert_file_exists(rpfp)
  rpfp
}

#' @rdname reference_posterior_draws_file_path
#' @export
reference_posterior_draws_file_path.pdb_reference_posterior_info <- function(x, pdb = pdb_default(), ...) {
  reference_posterior_draws_file_path(x$name, pdb, ...)
}


#' Reference Posterior draws and summary statistics
#' @param x a [posterior] object or a posterior name.
#' @param pdb a [pdb] object (if [x] is a posterior name)
#' @param info a [pdb_reference_posterior_info] object
#' @param ... further arguments supplied to specific methods.
#' @return a [pdb_reference_posterior] object.
#' @export
reference_posterior_draws <- function(x, ...){
  UseMethod("reference_posterior_draws")
}

#' @rdname reference_posterior_draws
#' @export
pdb_reference_posterior_draws <- reference_posterior_draws

#' @rdname reference_posterior_draws
#' @export
reference_posterior_draws.character <- function(x, pdb = pdb_default(), ...){
  reference_posterior_draws(posterior(x, pdb = pdb))
}

#' @rdname reference_posterior_draws
#' @export
reference_posterior_draws.pdb_posterior <- function(x, ...){
  read_reference_posterior_draws(x = x$reference_posterior_name, pdb = pdb(x))
}

#' @rdname reference_posterior_draws
#' @export
reference_posterior_draws.pdb_reference_posterior_info <- function(x, pdb = pdb_default(), ...){
  read_reference_posterior_draws(x = x$name, pdb = pdb)
}

#' @rdname reference_posterior_draws
#' @export
reference_posterior_draws.draws_list <- function(x, info, ...){
  checkmate::assert_class(info, "pdb_reference_posterior_info")
  x <- posterior::as_draws_list(posterior::as_draws(x))
  names(x) <- NULL
  for(i in seq_along(x)){
    x[[i]]$lp__ <- NULL
  }

  attr(x, "info") <- info
  class(x) <- c("pdb_reference_posterior_draws", class(x))
  assert_reference_posterior_draws(x)
  x
}


#' @rdname reference_posterior_draws
#' @export
assert_reference_posterior_draws <- function(x){
  checkmate::assert_class(x, c("pdb_reference_posterior_draws", "draws_list"))

  checkmate::assert_class(info(x), c("pdb_reference_posterior_info"))

  # Assert named chains has the same parameter names
  par_names <- lapply(x, names)
  for(i in seq_along(par_names)){
    checkmate::assert_true(identical(par_names[[1]],par_names[[i]]))
  }

  # Assert chains don't have names
  checkmate::assert_null(names(x))
}

#' Assert a [pdb_reference_posterior_info] object
#' @param x a an object to assert is a [pdb_reference_posterior_info] object.
#' @keywords internal
assert_reference_posterior_info <- function(x){
  checkmate::assert_class(x, "pdb_reference_posterior_info")
  checkmate::assert_names(names(x), identical.to = c("name", "inference", "diagnostics", "checks_made", "comments", "added_by", "added_date", "versions"))
  checkmate::assert_string(x$name)

  checkmate::assert_true(x$inference$method %in% c("stan_sampling", "analytical"))
  checkmate::assert_list(x$inference$method_arguments)

  if(!is.null(x$diagnostics)){
    checkmate::assert_names(names(x$diagnostics),
                            must.include = c("ndraws"))
    if(x$inference$method == "stan_sampling"){
      checkmate::assert_names(names(x$diagnostics),
                              must.include = c("nchains",
                                               "effective_sample_size_bulk",
                                               "effective_sample_size_tail",
                                               "r_hat",
                                               "divergent_transitions",
                                               "expected_fraction_of_missing_information"))
    }
  }
  if(!is.null(x$checks_made)){
    checkmate::assert_named(x$checks_made)
  }

  checkmate::assert_string(x$added_by)
  checkmate::assert_date(x$added_date)
  if(!is.null(x$versions)){
    checkmate::assert_names(names(x$versions), subset.of = c("rstan_version", "r_Makevars", "r_version", "r_session", "r_summary_statistic"))
    if(!is.null(x$versions$rstan_version)){
      checkmate::assert_names(names(x$versions), must.include = c("rstan_version", "r_Makevars", "r_version", "r_session"))
    }
    for(i in seq_along(x$versions)){
      checkmate::assert_string(x$versions[[i]])
    }
  }
}


#' Subset a [pdb_reference_posterior_draws] object
#' @param x a [pdb_reference_posterior_draws] to subest
#' @param variable parameter names to subset.
#' @param ... Further arguments (not used).
#' @export
subset.pdb_reference_posterior_draws <- function(x, variable, ...){
  requireNamespace("posterior")
  attrs <- attributes(x)
  class(x) <- class(x)[-1]
  x <- subset(x, variable = variable, regex = FALSE)
  attributes(x) <- attrs
  x
}


#' @export
print.pdb_reference_posterior_draws <- function(x, ...) {
  cat0("Reference Posterior: ", info(x)$name, "\n")
  NextMethod("print")
}

#' @export
summary.pdb_reference_posterior_draws <- function(object, ...) {
  cat0("Reference Posterior: ", info(object)$name, "\n")
  print(posterior::summarise_draws(object))
}


#' @export
print.pdb_reference_posterior_info <- function(x, ...) {
  cat0("Posterior: ", x$name, "\n")
  cat0("Method: ", x$inference$method, " (", x$versions[[1]], ")\n")
  cat0("Arguments:\n")
  print_list(x$inference$method_arguments)
}

supported_reference_posterior_types <- function() c("draws", supported_summary_statistic_types())

#' Thin draws to reduce their size and autocorrelation of the chains.
#'
#' @description Thin [pdb_reference_posterior_draws] objects to reduce their size and autocorrelation of the chains.
#'
#' @param x An R object for which the methods are defined.
#' @param thin A positive integer specifying the period for selecting draws.
#' @param ... Arguments passed to individual methods (if applicable).
#'
#' @return
#' A thinned [pdb_reference_posterior_draws] object.
#'
#' @export
thin_draws.pdb_reference_posterior_draws <- function(x, thin, ...){
  rpdi <- info(x)
  class(x) <- class(x)[-1]
  x <- posterior::thin_draws(x, thin, ...)
  x <- pdb_reference_posterior_draws(x, rpdi)
  checkmate::assert_class(x, "pdb_reference_posterior_draws")
  x
}
