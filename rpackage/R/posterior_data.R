#' Extract data for posterior
#' 
#' @param x a \code{posterior} object.
#' @export
posterior_data_file_path <- function(x){
  checkmate::assert_class(x, "posterior")
  checkmate::assert_file_exists(paste0(x$data, ".zip"))
  
  pdfp <- posterior_data_temp_file_path(x)
  
  if(!checkmate::test_file_exists(pdfp)){
    dir.create(posterior_data_temp_dir(), recursive = TRUE, showWarnings = FALSE)
    file.copy(from = paste0(x$data, ".zip"), to = paste0(pdfp, ".zip"))
    unzip(zipfile = paste0(pdfp, ".zip"), exdir = posterior_data_temp_dir())
    file.remove(paste0(pdfp, ".zip"))
  }
  
  pdfp
}

#' @rdname posterior_data_file_path
#' @export
posterior_data <- function(x){
  pdfp <- posterior_data_file_path(x)
  dat <- jsonlite::read_json(pdfp, simplifyVector = TRUE)
  dat
}

posterior_data_temp_dir <- function() file.path(tempdir(), "posteriors", "data")

posterior_data_file_name <- function(x) {
  dfn <- strsplit(x$data, split = "/")[[1]]
  dfn[length(dfn)]
}

posterior_data_temp_file_path <- function(x) file.path(posterior_data_temp_dir(), posterior_data_file_name(x))

