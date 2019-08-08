
#' @export
data <- function (x, ...) {
  UseMethod("data")
}

#' @export
data.posterior <- function (x, ..., tempdir = TRUE){
  sdfp <- data_file_path(x, tempdir)
  dat <- jsonlite::read_json(sdfp, simplifyVector = TRUE)
  dat
}

#' @export
data.default <- function (x, ..., list = character(), package = NULL, lib.loc = NULL, 
                          verbose = getOption("verbose"), envir = .GlobalEnv) {
  utils::data(x, list = character(), package = NULL, lib.loc = NULL, 
              verbose = getOption("verbose"), envir = .GlobalEnv)
}


#' Extract data for posterior
#' 
#' @param x a \code{posterior} object.
#' @export
data_file_path <- function(x, tempdir = TRUE){
  checkmate::assert_class(x, "posterior")
  checkmate::assert_file_exists(file.path(x$pdb$path, paste0(x$data, ".zip")))
  pdfp <- posterior_data_temp_file_path(x)
  
  if(!checkmate::test_file_exists(pdfp)){
    dir.create(posterior_data_temp_dir(), recursive = TRUE, showWarnings = FALSE)
    file.copy(from = file.path(x$pdb$path, paste0(x$data, ".zip")), to = paste0(pdfp, ".zip"))
    unzip(zipfile = paste0(pdfp, ".zip"), exdir = posterior_data_temp_dir())
    file.remove(paste0(pdfp, ".zip"))
  }
  
  pdfp
}


data_temp_dir <- function() file.path(tempdir(), "posteriors", "data")

data_file_name <- function(x) endpoint(x$data)

data_temp_file_path <- function(x) file.path(posterior_data_temp_dir(), posterior_data_file_name(x))


#' @rdname data_file_path
#' @export
stan_data_file_path <- function(x){
  data_file_path(x)
}

#' @rdname stan_data_file_path
#' @export
stan_data <- function(x){
  data(x)
}
