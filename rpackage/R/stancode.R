#' Extract stan code file path from posterior
#' 
#' @param x a \code{posterior} object.
#' @export
stancode_file_path <- function(x){
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

#' @rdname stancode_file_path
#' @export
stancode <- function(x){
  scfp <- stancode_file_path(x)
  readLines(scfp)
}

stan_code_temp_dir <- function() file.path(tempdir(), "posteriors", "stan_code")

stan_code_file_name <- function(x) {
  scfn <- strsplit(x$model$stan, split = "/")[[1]]
  scfn[length(scfn)]
}
