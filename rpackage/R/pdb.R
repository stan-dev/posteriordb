#' Create a Posterior Database (pdb) connection
#'
#' @details
#' Connect to a posterior database locally or in a github repo.
#'
#' @param cache_path The path to the pdb cache. Default is R temporary directory.
#' This is used to store files locally and without affecting the database.
#' @param pdb_id how to identify the pdb (path for local pdb, repo for github pdb)
#' @param pdb_type Type of posterior database connection. Either \code{local} or \code{github}.
#' @param path a local path to a posterior database.
#' @param repo Repository address in the format
#'   `username/repo[/subdir][@@ref|#pull]`. Alternatively, you can
#'   specify `subdir` and/or `ref` using the respective parameters
#'   (see below); if both is specified, the values in `repo` take
#'   precedence.
#' @param ref Desired git reference. Could be a commit, tag, or branch
#'   name. Defaults to `"master"`.
#' @param subdir subdirectory within repo that contains the posterior database.
#' @param auth_token To use a private repo, generate a personal
#'   access token (PAT) in "https://github.com/settings/tokens" and
#'   supply to this argument. This is safer than using a password because
#'   you can easily delete a PAT without affecting any others. Defaults to
#'   the `GITHUB_PAT` environment variable.
#' @param host GitHub API host to use. Override with your GitHub enterprise
#'   hostname, for example, `"github.hostname.com/api/v3"`.
#' @param ... further arguments for specific methods to setup a pdb.
#' @return a \code{pdb} object
#'
#' @export
pdb_local <- function(path = getOption("pdb_path", file.path(getwd(), "posterior_database")),
                      cache_path = tempdir()){
  pdb(pdb_id = path, pdb_type = "local", cache_path = cache_path)
}

#' @rdname pdb_local
#' @export
pdb <- function(pdb_id, pdb_type = "local", cache_path = tempdir(), ...) {
  checkmate::assert_directory(cache_path, "w")
  checkmate::assert_choice(pdb_type, c("local", "github"))
  if(cache_path == tempdir()){
    # To ensure no duplicate file names from R session.
    cache_path <- file.path(cache_path, "posteriordb_cache")
  }
  if(!dir.exists(cache_path)) dir.create(cache_path)
  pdb <- list(
    pdb_id = pdb_id,
    cache_path = cache_path
  )
  class(pdb) <- c(paste0("pdb_", pdb_type), "pdb")
  pdb <- setup_pdb(pdb, ...)
  pdb$version <- pdb_version(pdb)
  pdb
}

#' @rdname pdb_local
pdb_official <- function(cache_path = tempdir()){
  pdb_github("MansMeg/posteriordb/posterior_database", cache_path = cache_path)
}

#' Setup object specific part of pdb object
#' @param pdb a \code{pdb} object.
#' @param ... further arguments supplied to specific methods (not in use)
#' @keywords internal
setup_pdb <- function(pdb, ...){
  UseMethod("setup_pdb")
}

#' @rdname setup_pdb
setup_pdb.pdb_local <- function(pdb, ...){
  pdb <- pdb_endpoint(pdb)
  checkmate::assert_directory(pdb$pdb_local_endpoint, "r")
  pdb
}

#' Get version of the \code{pdb}
#'
#' @param pdb a \code{pdb} object to return version for.
#'
#' @return the git sha for the posterior database.
#' @export
pdb_version <- function(pdb, ...){
  if(!is.null(pdb$version)) return(pdb$version)
  UseMethod("pdb_version")
}

#' @rdname pdb_version
#' @export
pdb_version.pdb_local <- function(pdb, ...){
  repo <- git2r::repository(pdb$pdb_local_endpoint)
  r <- git2r::revparse_single(repo, "HEAD")
  list("sha" = git2r::sha(r))
}

#' Get all existing posterior names from a posterior database.
#'
#' @param pdb a \code{pdb} object.
#' @param ... further arguments supplied to specific methods (not in use)
#' @export
posterior_names <- function(pdb, ...) {
  UseMethod("posterior_names")
}

#' @export
posterior_names.pdb_local <- function(pdb, ...) {
  pns <- dir(file.path(pdb$pdb_local_endpoint, "posteriors"))
  remove_file_extension(pns)
}

#' @export
names.pdb <- function(x) {
  posterior_names(x)
}

#' Get all existing model names from a posterior database
#'
#' @param pdb a \code{pdb} object.
#' @param ... Further argument to methods.
#' @export
model_names <- function(pdb, ...) {
  UseMethod("model_names")
}

#' @rdname model_names
#' @export
model_names.pdb_local <- function(pdb, ...) {
  pns <- dir(file.path(pdb$pdb_local_endpoint, "models"),
             recursive = TRUE, full.names = FALSE)
  pns <- pns[grepl(pns, pattern = "\\.json$")]
  basename(remove_file_extension(pns))
}

#' Get all existing data names from a posterior database
#'
#' @param pdb a \code{pdb} object.
#' @param ... Further argument to methods.
#'
#' @export
data_names <- function(pdb, ...) {
  UseMethod("data_names")
}

#' @rdname data_names
#' @export
data_names.pdb_local <- function(pdb, ...) {
  pns <- dir(file.path(pdb$pdb_local_endpoint, "data"),
             recursive = TRUE, full.names = FALSE)
  pns <- pns[grepl(pns, pattern = "\\.json\\.zip$")]
  basename(remove_file_extension(pns))
}


#' @export
print.pdb <- function(x, ...) {
  cat0("Posterior Database (", pdb_type(x), ")\n")
  cat0("Path: ", x$pdb_id, "\n")
  cat0("Version:\n")
  for (vn in names(x$version)) {
    cat0("  ", vn, ":", x$version[[vn]], "\n")
  }
  invisible(x)
}

#' Extract the pdb type from class name
#' @noRd
#' @param a \code{pdb} object.
#' @keywords internal
pdb_type <- function(pdb){
  strsplit(class(pdb)[1], split = "_")[[1]][2]
}


#' Set and check posterior database endpoint
#' i.e. after this has run, the pdb points to the
#' posterior db root. Local pdb search all folders below
#' Github pdb just checks that the supplied github repo
#' (with subdir) points to the pdb
#' @noRd
#' @param pdb a \code{pdb} object.
#' @param ... further arguments supplied to class specific methods.
#' @return a \code{pdb} object with set/checked endpoint.
#' @keywords internal
pdb_endpoint <- function(pdb, ...) {
  UseMethod("pdb_endpoint")
}

#' @noRd
#' @rdname pdb_endpoint
#' @keywords internal
pdb_endpoint.pdb_local <- function(pdb, ...) {
  if(!is.null(pdb$pdb_local_endpoint)) return(pdb$pdb_local_endpoint)
  checkmate::assert_directory(pdb$pdb_id)
  pdb$pdb_local_endpoint <- normalizePath(pdb$pdb_id)
  while (!is_pdb_endpoint(pdb) & basename(pdb$pdb_local_endpoint) != "") {
    pdb$pdb_endpoint <- dirname(pdb$pdb_local_endpoint)
  }
  if (basename(pdb$pdb_local_endpoint) == "") {
    stop2("No posterior database in path '", pdb$pdb_id, "'.")
  }
  pdb
}


#' Check if the current pdb points to a posterior database endpoint
#' @noRd
#' @param pdb a \code{pdb} object.
#' @param ... further arguments supplied to class specific methods.
#' @return a boolean
#' @keywords internal
is_pdb_endpoint <- function(pdb, ...) {
  UseMethod("is_pdb_endpoint")
}

pdb_minimum_contents <- function() c("data", "models", "posteriors", "references")

#' @noRd
#' @rdname is_pdb_endpoint
#' @keywords internal
is_pdb_endpoint.pdb_local <- function(pdb, ...) {
  checkmate::assert_directory_exists(pdb$pdb_local_endpoint)
  all(pdb_minimum_contents() %in% dir(pdb$pdb_local_endpoint))
}


#' Read json file from \code{path}
#'
#' @details
#' Copies the file to the cache and return path
#'
#' @param pdb a \code{pdb} to read from.
#' @param path a \code{pdb} to read from.
#' @param unzip if true, path is zipped and should be unzipped to cache.
#' @importFrom utils unzip
pdb_cached_local_file_path <- function(pdb, path, unzip = FALSE){
  checkmate::assert_class(pdb, "pdb")
  checkmate::assert_string(path)
  checkmate::assert_flag(unzip)

  # Check if path in cache - return cached path
  cp <- pdb_cache_path(pdb, path)
  if(file.exists(cp)) return(cp)

  # Assert file exists
  if(unzip) {
    path_zip <- paste0(path, ".zip")
    pdb_assert_file_exist(pdb, path_zip)
  } else {
    pdb_assert_file_exist(pdb, path)
  }

  # Copy (and unzip) file to cache
  if(unzip){
    cp_zip <- paste0(cp, ".zip")
    pdb_file_copy(pdb, path_zip, cp_zip, overwrite = TRUE)
    utils::unzip(zipfile = cp_zip, exdir = dirname(cp_zip))
  } else {
    pdb_file_copy(pdb, from = path, to = cp, overwrite = TRUE)
  }

  return(cp)
}

#' Returns a writable cache path for a pdb and a path
#' It will create the directory if it does not exist.
#' @param pdb a \code{pdb} object.
#' @param path a \code{pdb} path.
pdb_cache_path <- function(pdb, path){
  cp <- file.path(pdb$cache_path, path)
  dir.create(dirname(cp), showWarnings = FALSE, recursive = TRUE)
  cp
}

#' Copy a file from a pdb to a local path
#'
#' @param pdb a \code{pdb} connection.
#' @param from a path in the pdb
#' @param to a local file path
#' @param overwrite overwrite local file.
#' @param ... further argument supplied to methods
#' @return a boolean indicator as file.copy indicating success.
pdb_file_copy <- function(pdb, from, to, overwrite = FALSE, ...){
  checkmate::assert_class(pdb, "pdb")
  checkmate::assert_string(from)
  pdb_assert_file_exist(pdb, from)
  checkmate::assert_path_for_output(to)
  checkmate::assert_flag(overwrite)
  UseMethod("pdb_file_copy")
}

#' @rdname pdb_file_copy
pdb_file_copy.pdb_local <- function(pdb, from, to, overwrite = FALSE, ...){
  file.copy(from = file.path(pdb$pdb_local_endpoint, from), to = to, overwrite = overwrite, ...)
}

#' Assert that a file exists
#' @param pdb a \code{pdb} object.
#' @param path a \code{pdb} path.
#' @param ... further arguments supplied to methods.
pdb_assert_file_exist <- function(pdb, path, ...){
  UseMethod("pdb_assert_file_exist")
}

#' @rdname pdb_assert_file_exist
pdb_assert_file_exist.pdb_local <- function(pdb, path, ...){
  checkmate::assert_file_exists(file.path(pdb$pdb_local_endpoint, path))
}

#' Clear posterior database cache
#' @param pdb a \code{pdb} to clear cache for
#' @keywords internal
pdb_clear_cache <- function(pdb){
  cached_files <- dir(pdb_cache_path(pdb, ""), recursive = TRUE, full.names = TRUE)
  file.remove(cached_files)
}


#' Check a posterior database
#' @noRd
#' @param pdb a \code{pdb} object
#' @param posterior_idx an index vector indicating what posteriors to check.
#' @return a boolean indicating if the pdb works as it should.
check_pdb <- function(pdb, posterior_idx = NULL) {
  checkmate::assert_class(pdb, "pdb")
  message("Checking posterior database...")
  pns <- names(pdb)
  if(!is.null(posterior_idx)) pns <- pns[posterior_idx]
  pl <- list()
  for (i in seq_along(pns)) {
    pl[[i]] <- posterior(name = pns[i], pdb = pdb)
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
