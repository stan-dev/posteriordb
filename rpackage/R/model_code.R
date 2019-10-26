#' Extract file paths to model code from posterior object
#'
#' @param x a \code{posterior} object.
#' @param framework model code framework (e.g. \code{stan}).
#'
#' @export
model_code_file_path <- function(x, framework) {
  checkmate::assert_class(x, "pdb_posterior")
  checkmate::assert_choice(framework, names(x$model_info$model_code))
  mcfp <- pdb_cached_local_file_path(x$pdb, x$model_info$model_code[[framework]])
  mcfp
}

#' @rdname model_code_file_path
#' @export
model_code <- function(x, framework) {
  checkmate::assert_class(x, "pdb_posterior")
  scfp <- model_code_file_path(x, framework)
  out <- paste0(readLines(scfp), collapse = "\n")
  class(out) <- "pdb_model_code"
  out
}
#' @rdname model_code_file_path
#' @export
pdb_model_code <- model_code

#' @export
print.pdb_model_code <- function(x, ...) {
  cat(x)
  invisible(x)
}

model_code_file_name <- function(x, framework) {
  basename(model_code_file_path(x, framework))
}

#' @rdname model_code_file_path
#' @export
stan_code_file_path <- function(x) {
  checkmate::assert_class(x, "pdb_posterior")
  model_code_file_path(x, "stan")
}

#' @rdname model_code_file_path
#' @export
stan_code <- function(x) {
  checkmate::assert_class(x, "pdb_posterior")
  model_code(x, "stan")
}

#' @rdname model_code_file_path
#' @export
pdb_stan_code <- stan_code
