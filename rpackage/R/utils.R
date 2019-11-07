remove_file_extension <- function(x) {
  checkmate::assert_character(x, pattern = "\\..{1,5}$")
  unlist(lapply(strsplit(x, "\\."), function(x) x[1]))
}

get_file_extension <- function(x) {
  checkmate::assert_character(x, pattern = "\\..{1,5}$")
  unlist(lapply(strsplit(x, "\\."), function(x) x[2]))
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

#' Coerce to a Data Frame
#' @param x any R object.
#' @param NULL or a character vector giving the row names for the data frame. Missing values are not allowed.
#' @param optional Not used.
#' @export
as.data.frame.pdb_posteriors_info <- function(x, row.names = NULL, optional = FALSE, ...){
  pdb_idx <- which(names(x) == "pdb")
  keywords_idx <- which(names(x) == "keywords")
  x[unlist(lapply(x, length)) == 0] <- ""
  kws <- unlist(x$keywords)
  df <- as.data.frame(x[-c(keywords_idx, pdb_idx)], stringsAsFactors = FALSE)[rep(1, max(1,length(kws))), ]
  if(length(kws) == 0){
    df$keywords <- ""
  } else {
    df$keywords <- kws
  }
  rownames(df) <- row.names
  df
}
