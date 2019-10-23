#' Posterior database (pdb) constructor
#'
#' @param path a path to the posterior database
#' (i.e. where folders content and posteriors exists)
#'
#' @return a \code{pdb} object
#'
#' @export
pdb <- function(path = getOption("pdb_path", getwd())) {
  assert_pdb_dir(path)
  pdb <- list(
    path = path,
    # TODO: make a S3 pdb_version class and add slots
    version = list()
  )
  class(pdb) <- "pdb"
  pdb
}

#' Check a posterior database
#' @noRd
#' @param pdb a \code{pdb} object
#' @return a boolean indicating if the pdb works as it should.
check_pdb <- function(pdb) {
  checkmate::assert_class(pdb, "pdb")
  message("Checking posterior database...")
  pns <- names(pdb)
  pl <- list()
  for (i in seq_along(pns)) {
    pl[[i]] <- posterior(pns[i], pdb = pdb)
  }
  message("1. All posteriors can be read.")
  for (i in seq_along(pl)) {
    stan_code(pl[[i]])
  }
  message("2. All stan_code can be read.")
  for (i in seq_along(pl)) {
    stan_data(x = pl[[i]])
  }
  message("3. All stan_data can be read.")
  message("Posterior database is ok.\n")
  invisible(TRUE)
}

#' Get all existing posterior names from a posterior database
#'
#' @param pdb a \code{pdb} object.
#' @export
posterior_names <- function(pdb) {
  checkmate::assert_class(pdb, "pdb")
  pns <- dir(file.path(pdb$path, "posteriors"))
  remove_file_extension(pns)
}

#' @export
names.pdb <- function(x) {
  posterior_names(x)
}

#' Get all existing model names from a posterior database
#'
#' @param pdb a \code{pdb} object.
#' @export
model_names <- function(pdb) {
  checkmate::assert_class(pdb, "pdb")
  pns <- dir(file.path(pdb$path, "content", "models"),
             recursive = TRUE, full.names = FALSE)
  pns <- pns[grepl(pns, pattern = "\\.json$")]
  basename(remove_file_extension(pns))
}

#' Get all existing data names from a posterior database
#'
#' @param pdb a \code{pdb} object.
#' @export
data_names <- function(pdb) {
  checkmate::assert_class(pdb, "pdb")
  pns <- dir(file.path(pdb$path, "content", "data"),
             recursive = TRUE, full.names = FALSE)
  pns <- pns[grepl(pns, pattern = "\\.json\\.zip$")]
  basename(remove_file_extension(pns))
}

#' @export
print.pdb <- function(x, ...) {
  cat0("Posterior Database\n")
  cat0("Path: ", x$path, "\n")
  cat0("Version:\n")
  for (vn in names(x$version)) {
    cat0("  ", vn, ":", x$version[[vn]], "\n")
  }
  invisible(x)
}

pdb_dir_entrypoint <- function(x) {
  checkmate::assert_directory(x)
  fp <- normalizePath(x)
  while (!is.pdb_dir(fp) & basename(fp) != "") {
    fp <- dirname(fp)
  }
  if (basename(fp) == "") {
    stop2("No posterior database in path '", x, "'.")
  }
  fp
}

is.pdb_dir <- function(x) {
  checkmate::assert_directory_exists(x)
  all(c("content", "posteriors") %in% dir(x))
}

assert_pdb_dir <- function(x) {
  if (!is.pdb_dir(x)) {
    stop2("'", x, "' is not a path to a posterior database.")
  }
  invisible(x)
}
