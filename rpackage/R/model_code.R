#' Extract file paths to model code from posterior object
#'
#' @param x an object to access file path to.
#' @param framework model code framework (e.g. \code{stan}).
#' @param pdb a \code{pdb} object.
#' @param info a \code{pdb_model_info} object.
#' @param ... further arguments supplied to methods.
#'
#' @seealso framework()
#'
#' @export
model_code <- function(x, ...) {
  UseMethod("model_code")
}

#' @rdname model_code
#' @export
model_code.pdb_posterior <- function(x, framework, ...) {
  model_code(x$model_name, framework, pdb = pdb(x), ...)
}

#' @rdname model_code
#' @export
model_code.character <- function(x, framework, pdb = pdb_default(), ...) {
  checkmate::assert_string(x)
  scfp <- model_code_file_path(x, framework, pdb, ...)
  out <- paste0(readLines(scfp), collapse = "\n")
  class(out) <- c("pdb_model_code", "character")
  framework(out) <- framework
  info(out) <- model_info(x, pdb = pdb)
  pdb(out) <- pdb
  assert_model_code(out)
  out
}

#' @rdname model_code
#' @export
model_code.pdb_model_info <- function(x, framework, pdb = pdb_default(), ...) {
  model_code(x$name, framework, pdb, ...)
}

#' @rdname model_code
#' @export
model_code.stanmodel <- function(x, info, ...){
  mc <- x@model_code
  class(mc) <- "pdb_model_code"
  framework(mc) <- "stan"
  info(mc) <- info
  assert_model_code(mc)
  mc
}

#' @rdname model_code
#' @export
pdb_model_code <- model_code



#' @rdname model_code
#' @export
model_code_file_path <- function(x, ...) {
  UseMethod("model_code_file_path")
}

#' @rdname model_code
#' @export
model_code_file_path.pdb_posterior <- function(x, framework, ...) {
  checkmate::assert_choice(framework, names(x$model_info$model_implementations))
  mcfp <- pdb_cached_local_file_path(pdb(x), x$model_info$model_implementations[[framework]]$model_code)
  mcfp
}

#' @rdname model_code
#' @export
model_code_file_path.pdb_model_info <- function(x, framework, pdb = pdb_default(), ...) {
  model_code_file_path(x$name, framework, pdb, ...)
}

#' @rdname model_code
#' @export
model_code_file_path.character <- function(x, framework, pdb = pdb_default(), ...) {
  fn <- paste0(x, ".", framework)
  mcfp <- pdb_cached_local_file_path(pdb = pdb, path = file.path("models", framework, fn), unzip = FALSE)
  mcfp
}

#' @export
print.pdb_model_code <- function(x, ...) {
  cat(x)
  invisible(x)
}

#' @rdname model_code
#' @export
stan_code_file_path <- function(x) {
  checkmate::assert_class(x, "pdb_posterior")
  model_code_file_path(x, "stan")
}

#' @rdname model_code
#' @export
stan_code <- function(x, ...) {
  model_code(x, framework = "stan", ...)
}

#' @rdname model_code
#' @export
pdb_stan_code <- stan_code


assert_model_code <- function(x){
  checkmate::assert_class(x, "pdb_model_code")
  checkmate::assert_string(x)
  checkmate::assert_choice(framework(x), choices = supported_frameworks())
  checkmate::assert_class(info(x), "pdb_model_info")
}

#' Identify the framework for a given [model_code]
#'
#' @param x a [pdb_model_code] object.
#' @param value a supported framework.
#'
#' @export
framework <- function(x){
  UseMethod("framework")
}

#' @rdname framework
#' @export
framework.pdb_model_code <- function(x){
  attr(x, which = "framework")
}

#' @rdname framework
#' @export
`framework<-` <- function(x, value){
  UseMethod("framework<-")
}

#' @rdname framework
#' @export
`framework<-.character` <- function(x, value){
  checkmate::assert_choice(value, supported_frameworks())
  attr(x, "framework") <- value
  x
}

#' @rdname framework
#' @export
`framework<-.pdb_model_code` <- function(x, value){
  checkmate::assert_choice(value, supported_frameworks())
  x <- `framework<-.character`(x, value)
  x
}

supported_frameworks <- function() c("stan", "pymc3", "tfp", "pyro")
