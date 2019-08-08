#' Extract stan code file path or stan code from posterior object
#' 
#' @param x a \code{posterior} object.
#' @export
stan_code_file_path <- function(x, in_tmp_dir = TRUE){
  checkmate::assert_class(x, "posterior")
  assert_has_stan_code(x)
  mfp <- model_code_file_paths(x)
  if(in_tmp_dir){
    scfn <- stan_code_file_name(x)
    scfp <- file.path(stan_code_temp_dir(), scfn)
    if(!checkmate::test_file_exists(scfp)){
      dir.create(stan_code_temp_dir(), recursive = TRUE, showWarnings = FALSE)
      file.copy(from = mfp[["stan"]], to = scfp)
    }
    return(scfp)
  } else {
    return(mfp[["stan"]])
  }
}

#' @rdname stan_code_file_path
#' @export
stan_code <- function(x){
  checkmate::assert_class(x, "posterior")
  scfp <- stan_code_file_path(x)
  readLines(scfp)
}

stan_code_temp_dir <- function() file.path(tempdir(), "posteriors", "stan_code")

stan_code_file_name <- function(x) {
  checkmate::assert_class(x, "posterior")
  assert_has_stan_code(x)
  mfp <- model_code_file_paths(x)
  endpoint(mfp[["stan"]])
}

assert_has_stan_code <- function(x){
  mfp <- model_code_file_paths(x)
  if(!"stan" %in% names(mfp)) stop("No stan code for model ", model_names(x))
}
