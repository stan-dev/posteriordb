#' Extract stan code file path or stan code from posterior object
#' 
#' @param x a \code{posterior} object.
#' @export
stan_code_file_path <- function(x){
  checkmate::assert_class(x, "posterior")
  checkmate::assert_file_exists(x$model$stan)
  scfn <- stan_code_file_name(x)
  scfp <- file.path(stan_code_temp_dir(), scfn)
  if(!checkmate::test_file_exists(scfp)){
    dir.create(stan_code_temp_dir(), recursive = TRUE, showWarnings = FALSE)
    file.copy(from = x$model$stan, to = scfp)
  }
  scfp
}

#' @rdname stan_code_file_path
#' @export
stan_code <- function(x){
  scfp <- stan_code_file_path(x)
  readLines(scfp)
}

stan_code_temp_dir <- function() file.path(tempdir(), "posteriors", "stan_code")

stan_code_file_name <- function(x) endpoint(x$model$stan)
