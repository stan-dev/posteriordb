#' Extract file paths to model code from posterior object
#'
#' @param x a \code{posterior} object.
#' @param framework model code framework (e.g. \code{stan}).
#' @param tempdir Should the file be copied to R temporary directory? Default is \code{TRUE}.
#'
#' @export
model_code_file_path <- function(x, framework, tempdir = TRUE){
  checkmate::assert_class(x, "posterior")
  checkmate::assert_choice(framework, names(x$model_info$model_code))

  mcfp <- file.path(x$pdb$path, x$model_info$model_code[[framework]])
  if(tempdir){
    mcfn <- model_code_file_name(x, framework)
    tmcfp <- file.path(model_code_temp_dir(), framework, mcfn)
    if(!checkmate::test_file_exists(tmcfp)){
      dir.create(file.path(model_code_temp_dir(), framework), recursive = TRUE, showWarnings = FALSE)
      file.copy(from = mcfp, to = tmcfp)
    }
    mcfp <- tmcfp
  }
  checkmate::assert_file_exists(mcfp)
}

#' @rdname model_code_file_path
#' @export
model_code <- function(x, framework){
  checkmate::assert_class(x, "posterior")
  scfp <- model_code_file_path(x, framework, FALSE)
  readLines(scfp)
}

model_code_temp_dir <- function() file.path(tempdir(), "posteriors", "model_code")

model_code_file_name <- function(x, framework) {
  basename(model_code_file_path(x, framework, FALSE))
}

#' @rdname model_code_file_path
#' @export
stan_code_file_path <- function(x, tempdir = TRUE){
  checkmate::assert_class(x, "posterior")
  model_code_file_path(x, "stan", tempdir)
}

#' @rdname model_code_file_path
#' @export
stan_code <- function(x){
  checkmate::assert_class(x, "posterior")
  model_code(x, "stan")
}
