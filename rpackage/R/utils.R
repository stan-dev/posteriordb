
remove_file_extension <- function(x){
  checkmate::assert_character(x, pattern = "\\..{1,5}$")
  unlist(lapply(strsplit(x, "\\."), function(x) x[1]))
}

endpoint <- function(x){
  x <- strsplit(x, split = "/|\\")[[1]]
  x[length(x)]
}