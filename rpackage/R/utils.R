remove_file_extension <- function(x) {
  checkmate::assert_character(x, pattern = "\\..{1,5}$")
  unlist(lapply(strsplit(x, "\\."), function(x) x[1]))
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

get_pdb_dir <- function(x) {
  fp <- normalizePath(x)
  while (!is.pdb_dir(fp) & basename(fp) != "") {
    fp <- dirname(fp)
  }
  if (basename(fp) == "") {
    stop2("No posterior database in path '", x, "'.")
  }
  fp
}
