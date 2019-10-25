remove_file_extension <- function(x) {
  checkmate::assert_character(x, pattern = "\\..{1,5}$")
  unlist(lapply(strsplit(x, "\\."), function(x) x[1]))
}

get_file_extension <- function(x) {
  checkmate::assert_character(x, pattern = "\\..{1,5}$")
  unlist(lapply(strsplit(x, "\\."), function(x) x[2]))
}

#' @noRd
#' @param from path to ziped file
#' @param to path to unziped file
#' @importFrom utils unzip
copy_and_unzip <- function(from, to, overwrite = FALSE) {
  checkmate::assert_file_exists(from)
  checkmate::assert_flag(overwrite)
  if (!checkmate::test_file_exists(to) || overwrite) {
    dir.create(dirname(to), recursive = TRUE, showWarnings = FALSE)
    checkmate::assert_path_for_output(to)
    file.copy(from = from, to = paste0(to, ".zip"))
    utils::unzip(zipfile = paste0(to, ".zip"), exdir = dirname(to))
    file.remove(paste0(to, ".zip"))
  }
  invisible(NULL)
}

stop2 <- function(...) {
  stop(..., call. = FALSE)
}

warning2 <- function(...) {
  warning(..., call. = FALSE)
}

# cat with without separating elements
cat0 <- function(..., file = "", fill = FALSE, labels = NULL, append = FALSE) {
  cat(..., sep = "", file = file, fill = fill, labels = labels, append = append)
}

# file.path that remove null elementd
file.path0 <- function(...){
  arg <- list(...)
  do.call(file.path, arg[!unlist(lapply(arg, FUN = is.null))])
}
