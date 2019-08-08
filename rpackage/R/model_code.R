#' Extract file paths to model codes from posterior object
#' 
#' @param x a \code{posterior} object.
#' 
#' @return a list with paths to different model codes
#' 
#' @export
model_code_file_paths <- function(x){
  checkmate::assert_class(x, "posterior")
  mcfp <- x$model
  for(i in seq_along(x$model)){
    mcfp[[i]] <- file.path(x$pdb$path, x$model[[i]])
    checkmate::assert_file_exists(mcfp[[i]])
  }
  mcfp
}
