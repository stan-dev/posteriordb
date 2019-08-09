#' Posterior Data Sets
#' 
#' @param x a \code{posterior} object to access dataset from.
#' @param ... Currently not used.
#' 
#' @export
dataset <- function (x, ...) {
  UseMethod(object = x, generic = "dataset")
}


#' @rdname data
#' @export
dataset.posterior <- function (x, ...){
  sdfp <- dataset_file_path(x)
  dat <- jsonlite::read_json(sdfp, simplifyVector = TRUE)
  dat
}



#' Extract data for posterior
#' 
#' @inheritParams model_code_file_path
#' @importFrom utils unzip
#' @export
dataset_file_path <- function(x, tempdir = TRUE){
  checkmate::assert_class(x, "posterior")
  checkmate::assert_file_exists(file.path(x$pdb$path, paste0(x$data, ".zip")))
  pdfp <- dataset_temp_file_path(x)
  
  if(!checkmate::test_file_exists(pdfp)){
    dir.create(dataset_temp_dir(), recursive = TRUE, showWarnings = FALSE)
    file.copy(from = file.path(x$pdb$path, paste0(x$data, ".zip")), to = paste0(pdfp, ".zip"))
    unzip(zipfile = paste0(pdfp, ".zip"), exdir = dataset_temp_dir())
    file.remove(paste0(pdfp, ".zip"))
  }
  
  pdfp
}


dataset_temp_dir <- function() file.path(tempdir(), "posteriors", "data")

dataset_file_name <- function(x) basename(x$data)

dataset_temp_file_path <- function(x) file.path(dataset_temp_dir(), dataset_file_name(x))


#' @rdname dataset_file_path
#' @export
stan_dataset_file_path <- function(x){
  dataset_file_path(x)
}

#' @rdname dataset_file_path
#' @export
stan_data <- function(x){
  dataset(x)
}

#' @rdname dataset_file_path
#' @export
stan_dataset <- function(x){
  dataset(x)
}
