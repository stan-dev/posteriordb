#' Gold standard information
#'
#' @details
#' Gold standard information contain information on how, when and by whom
#' the gold standard was computed.
#'
#'
#' @param x a \code{posterior} object to access the gold standard for.
#' @param pdb a \code{pdb} posterior database connection.
#' @param ... Currently not used.
#'
#' @seealso gold_standard_draws
#'
#' @export
gold_standard_info <- function(x, pdb = pdb_default(), ...) {
  UseMethod("gold_standard_info")
}

#' @rdname gold_standard_info
#' @export
gold_standard_info.pdb_posterior <- function(x, ...) {
  read_gold_standard_info(x$gold_standard_name, x$pdb)
}

#' @rdname gold_standard_info
#' @export
gold_standard_info.character <- function(x, pdb = pdb_default(), ...) {
  gold_standard_info(posterior(x, pdb))
}


#' Read in gold standard information json object
#' @param x a data, model or posterior name
#' @param pdb a posterior db object to access the info json from
#' @noRd
#' @keywords internal
read_gold_standard_info <- function(x, pdb = NULL, ...) {
  if(is.null(x)) stop("There is currently no gold standard for this posterior.")
  gold_standard_info <- read_info_json(x, path = "gold_standards/info", pdb = pdb, ...)
  class(gold_standard_info) <- "pdb_gold_standard_info"
  assert_gold_standard_info(gold_standard_info)
  gold_standard_info
}



#' Read gold_standard_draws json object
#' @param x a data, model or posterior name
#' @param pdb a posterior db object to access the info json from
#' @param ... further arguments. Currently not used.
#' @noRd
#' @keywords internal
read_gold_standard_draws <- function(x, pdb, ...) {
  if(is.null(x)) stop("There is currently no gold standard for this posterior.")
  gsfp <- pdb_cached_local_file_path(pdb, file.path("gold_standards", "draws", paste0(x, ".json")), unzip = TRUE)
  gsd <- jsonlite::read_json(gsfp, simplifyVector = TRUE)
  gsd$draws <- posterior::as_draws(gsd$draws)
  class(gsd) <- c("pdb_gold_standard_draws", class(gsd))
  assert_gold_standard_draws(gsd)
  gsd
}

#' Extract data for posterior
#'
#' @inheritParams model_code_file_path
#' @export
gold_standard_draws_file_path <- function(x, ...) {
  UseMethod("gold_standard_draws_file_path")
}

#' @rdname gold_standard_draws_file_path
#' @export
gold_standard_draws_file_path.pdb_posterior <- function(x, ...) {
  if(is.null(x$gold_standard_name)) stop2("There is currently no gold standard for this posterior.")
  gold_standard_draws_file_path(x$gold_standard_name, pdb = x$pdb)
}

#' @rdname gold_standard_draws_file_path
#' @export
gold_standard_draws_file_path.character <- function(x, pdb = pdb_default(), ...) {
  checkmate::assert_string(x)
  fp <- paste0("gold_standards/draws/", x, ".json")
  gsfp <- pdb_cached_local_file_path(pdb, path = fp, unzip = TRUE)
  checkmate::assert_file_exists(gsfp)
  gsfp
}

#' @rdname gold_standard_draws_file_path
#' @export
gold_standard_draws_file_path.pdb_gold_standard_info <- function(x, pdb = pdb_default(), ...) {
  gold_standard_draws_file_path(x$name, pdb, ...)
}

#' Gold standard posterior draws
#' @param x a [posterior] object or a posterior name.
#' @param pdb a [pdb] object (if [x] is a posterior name)
#' @param ... further arguments supplied to specific methods.
#' @return a gold_standard, draws_list object.
#' @export
gold_standard_draws <- function(x, ...){
  UseMethod("gold_standard_draws")
}

#' @rdname gold_standard_draws
#' @export
gold_standard_draws.character <- function(x, pdb = pdb_default(), ...){
  gold_standard_draws(posterior(x, pdb = pdb))
}

#' @rdname gold_standard_draws
#' @export
gold_standard_draws.pdb_posterior <- function(x, ...){
  read_gold_standard_draws(x = x$gold_standard_name, pdb = x$pdb)
}

#' @rdname gold_standard_draws
#' @export
gold_standard_draws.pdb_gold_standard_info <- function(x, pdb = pdb_default(), ...){
  read_gold_standard_draws(x = x$name, pdb = pdb)
}

#' @rdname gold_standard_draws
#' @export
assert_gold_standard_draws <- function(x){
  checkmate::assert_class(x, c("pdb_gold_standard_draws"))

  checkmate::assert_names(names(x), subset.of = c("name", "draws"))

  checkmate::assert_string(x$name)
  checkmate::assert_class(x$draws, c("draws_list"))

  # Assert named chains has the same parameter names
  par_names <- lapply(x$draws, names)
  for(i in seq_along(par_names)){
    checkmate::assert_true(identical(par_names[[1]],par_names[[i]]))
  }
}

#' Assert a gold_standard info
#' @param x a an object to assert is a gold_standard_info object.
#' @keywords internal
assert_gold_standard_info <- function(x){
  checkmate::assert_class(x, "pdb_gold_standard_info")
  checkmate::assert_names(names(x), identical.to = c("name", "inference_method", "inference_method_arguments", "inference_version", "added_by", "added_date"))
  checkmate::assert_string(x$name)
  checkmate::assert_true(x$inference_method %in% c("stan_sampling", "analytical"))
  checkmate::assert_list(x$inference_method_arguments)
}

#' Subset a [pdb_gold_standard_draws] object
#' @param x a [pdb_gold_standard_draws] to subest
#' @param variable Parameters to subset.
#' @param ... Further arguments (not used).
#' @export
subset.pdb_gold_standard_draws <- function(x, variable, ...){
  requireNamespace("posterior")
  parameters <- paste0("^", variable, "(\\[[0-9]+\\])?$")
  x$draws <- subset(x$draws, variable = parameters, regex = TRUE)
  x
}


#' @export
print.pdb_gold_standard_draws <- function(x, ...) {
  cat0("Posterior: ", x$name, "\n")
  print(posterior::summarise_draws(x$draws))
}


#' @export
print.pdb_gold_standard_info <- function(x, ...) {
  cat0("Posterior: ", x$name, "\n")
  cat0("Method: ", x$inference_method, " (", x$inference_version, ")\n")
  cat0("Arguments:\n")
  print_list(x$inference_method_arguments)
}
