
remove_file_extension <- function(x){
  checkmate::assert_character(x, pattern = "\\..{1,5}$")
  unlist(lapply(strsplit(x, "\\."), function(x) x[1]))
}

endpoint <- function(x){
  x <- strsplit(x, split = "/|\\\\")
  unlist(lapply(x, FUN = function(x) x[length(x)]))
}

get_pdb_dir <- function(x){
  fp <- normalizePath(x)
  while(!is.pdb_dir(fp) & basename(fp) != ""){
    fp <- dirname(fp)
  }
  if(basename(fp) == "") stop("No posterior database in path '", x, "'.", call. = FALSE)
  fp
}
