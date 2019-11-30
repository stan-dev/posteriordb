#' Extract file paths to model code from posterior object
#'
#' @param x a \code{posterior} object.
#' @param framework model code framework (e.g. \code{stan}).
#'
#' @export
model_code_file_path <- function(x, framework, ...) {
  UseMethod("model_code_file_path")
}

#' @rdname model_code_file_path
#' @export
model_code_file_path.pdb_posterior <- function(x, framework, ...) {
  checkmate::assert_class(x, "pdb_posterior")
  checkmate::assert_choice(framework, names(x$model_info$model_code))
  mcfp <- pdb_cached_local_file_path(x$pdb, x$model_info$model_code[[framework]])
  mcfp
}

#' @rdname model_code_file_path
#' @export
model_code_file_path.character <- function(x, framework, pdb = pdb_default(), ...) {
  fn <- paste0(x, ".", framework)
  mcfp <- pdb_cached_local_file_path(pdb = pdb, path = file.path("models", framework, fn), unzip = FALSE)
  mcfp
}

#' @rdname model_code_file_path
#' @export
model_code <- function(x, framework, ...) {
  UseMethod("model_code")
}

#' @rdname model_code_file_path
#' @export
model_code.pdb_posterior <- function(x, framework, ...) {
  scfp <- model_code_file_path(x, framework)
  out <- paste0(readLines(scfp), collapse = "\n")
  class(out) <- "pdb_model_code"
  out
}

#' @rdname model_code_file_path
#' @export
model_code.character <- function(x, framework, pdb = pdb_default(), ...) {
  checkmate::assert_string(x)
  scfp <- model_code_file_path(x, framework, pdb, ...)
  out <- paste0(readLines(scfp), collapse = "\n")
  class(out) <- "pdb_model_code"
  out
}

#' @rdname model_code_file_path
#' @export
model_code.pdb_model_info <- function(x, framework, pdb = pdb_default(), ...) {
  scfp <- model_code_file_path(x$name, framework, pdb, ...)
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

#' @rdname model_code_file_path
#' @export
stan_code_file_path <- function(x) {
  checkmate::assert_class(x, "pdb_posterior")
  model_code_file_path(x, "stan")
}

#' @rdname model_code_file_path
#' @export
stan_code <- function(x, ...) {
  model_code(x, framework = "stan", ...)
}

#' @rdname model_code_file_path
#' @export
pdb_stan_code <- stan_code
