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
    # To ensure no duplicate temp file names from R session.
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

# Note, pdb_local contain all information on pdbs.
#' @rdname pdb_local
#' @export
pdb_default <- function(cache_path = tempdir()){
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
#' @param ... Further argument to methods.
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
posterior_names <- function(pdb = pdb_default(), ...) {
  pn(pdb, ...)
}

pn <- function(pdb, ...) {
  UseMethod("pn")
}

pn.pdb_local <- function(pdb, ...) {
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
model_names <- function(pdb = pdb_default(), ...) {
  UseMethod("model_names")
}

#' @rdname model_names
#' @export
model_names.pdb_local <- function(pdb = pdb_default(), ...) {
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
data_names <- function(pdb = pdb_default(), ...) {
  UseMethod("data_names")
}

#' @rdname data_names
#' @export
data_names.pdb_local <- function(pdb = pdb_default(), ...) {
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

pdb_minimum_contents <- function() c("data", "models", "posteriors")

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
  for(i in seq_along(cp)){
    if(!dir.exists(dirname(cp[i]))){
      dir.create(dirname(cp[i]), showWarnings = FALSE, recursive = TRUE)
    }
  }
  cp
}

#' Returns a cached files in path
#' @param pdb a \code{pdb} object.
#' @param path a \code{pdb} path.
#' @param file_ext should the file extensions be returned? Default is TRUE.
#' @param all.files see \code{dir()}.
#' @param full.names see \code{dir()}.
#' @param recursive see \code{dir()}.
#' @keywords internal
#' @noRd
pdb_list_files_in_cache <- function(pdb, path, file_ext = TRUE, all.files = FALSE, full.names = FALSE, recursive = FALSE){
  checkmate::assert_class(pdb, "pdb")
  checkmate::assert_string(path)
  checkmate::assert_flag(file_ext)
  checkmate::assert_flag(all.files)
  checkmate::assert_flag(full.names)
  checkmate::assert_flag(recursive)
  fns <- list.files(pdb_cache_path(pdb, path), all.files = all.files, full.names = full.names,  recursive = recursive)
  if(!file_ext) fns <- remove_file_extension(fns)
  fns
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
  checkmate::assert_path_for_output(to, overwrite = overwrite)
  checkmate::assert_flag(overwrite)
  UseMethod("pdb_file_copy")
}

#' @rdname pdb_file_copy
pdb_file_copy.pdb_local <- function(pdb, from, to, overwrite = FALSE, ...){
  pdb_assert_file_exist(pdb, from)
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
pdb_clear_cache <- function(pdb = pdb_default()){
  cached_files <- dir(pdb_cache_path(pdb, ""), recursive = TRUE, full.names = TRUE)
  file.remove(cached_files)
}


#' Cache a whole directory
#'
#' Mainly used for the filter functions
#' @noRd
#' @param pdb a \code{pdb} object.
#' @param path path to cache
#' @param ... further arguments supplied to class specific methods.
#' @return a boolean indicating success
#' @keywords internal
pdb_cache_dir <- function(pdb, path, ...){
  checkmate::assert_class(pdb, "pdb")
  checkmate::assert_choice(path, choices = c("posteriors", "models/info", "data/info", "reference_posteriors/info"))
  UseMethod("pdb_cache_dir")
}

#' @noRd
#' @rdname pdb_cache_dir
#' @keywords internal
pdb_cache_dir.pdb_local <- function(pdb, path, ...){
  fns <- dir(file.path(pdb$pdb_local_endpoint, path), full.names = FALSE)
  froms <- file.path(path, fns)
  tos <- pdb_cache_path(pdb = pdb, path = file.path(path, fns))
  for(i in seq_along(froms)){
    pdb_file_copy(pdb = pdb, from = froms[i], to = tos[i], overwrite = TRUE)
  }
}

#' Read in information json
#' @param x a data, model or posterior name
#' @param path one of \code{"posteriors"}, \code{"models/info"}, \code{"data/info"}
#' @param pdb a posterior db object to access the info json from
#' @noRd
#' @keywords internal
read_info_json <- function(x, path, pdb = NULL, ...){
  checkmate::assert_choice(path, c("posteriors", "models/info", "data/info", "reference_posteriors/draws", "reference_posteriors/expectations"))
  UseMethod("read_info_json")
}

#' @rdname read_info_json
#' @noRd
#' @keywords internal
read_info_json.character <- function(x, path, pdb = NULL, ...){
  checkmate::assert_class(pdb, "pdb")
  fn <- x
  if(path != "posteriors") {
    fn <- paste0(fn, ".info")
  }
  fp <- file.path(path, paste0(fn, ".json"))
  pfn <- pdb_cached_local_file_path(pdb, path = fp)
  po <- jsonlite::read_json(pfn, simplifyVector = TRUE)
  po$added_date <- as.Date(po$added_date)
  class(po) <- paste0("pdb_", gsub(x = path, pattern = "/", "_"))
  po
}

#' @rdname read_info_json
#' @noRd
#' @keywords internal
read_info_json.pdb_posterior <- function(x, path, pdb = NULL, ...){
  if(path == "posteriors"){
    nm <- x$name
  } else if(path == "models/info") {
    nm <- x$model_name
  } else if(path == "data/info") {
    nm <- x$data_name
  }
  po <- read_info_json(nm, path = path, pdb = x$pdb)
  po
}


#' Write objects to posteriordb
#' @param x a [reference_posterior_draws] object
#' @param path a posteriordb path.
#' @param info is this an info json?
#' @param type Output type, [json] or [txt].
#' @param name Used for code files and data.
#' @param overwrite Should an existing file be overwritten?
#' @param zip Should the json be zipped?
#' @param pdb a local posteriordb object to write to
#' @keywords internal
write_to_path <- function(x, path, type, pdb, name = NULL, zip = FALSE, info = TRUE, overwrite = FALSE){
  checkmate::assert_subset(class(x)[1], choices = c("character", "pdb_posterior", "pdb_model_info", "pdb_data_info", "pdb_data", "pdb_reference_posterior_draws", "pdb_reference_posterior_info"))
  checkmate::assert_string(path)
  checkmate::assert_class(pdb, "pdb_local")
  checkmate::assert_choice(type, c("json", "txt", "stan"))
  checkmate::assert_flag(zip)
  checkmate::assert_flag(info)

  if(is.null(name)){
    nm <- x$name
  } else {
    nm <- name
  }

  if(info) {
    nm <- paste0(nm, ".info.", type)
  } else {
    nm <- paste0(nm, ".", type)
  }

  path <- strsplit(path, "/")[[1]]
  fp <- file.path(pdb_endpoint(pdb), do.call(file.path, as.list(path)), nm)
  zfp <- paste0(fp, ".zip")
  if(zip){
    checkmate::assert_path_for_output(zfp, overwrite = overwrite)
  } else {
    checkmate::assert_path_for_output(fp, overwrite = overwrite)
  }

  if(type == "json"){
    out <- jsonlite::toJSON(x, pretty = TRUE, auto_unbox = TRUE, null = "null", digits = NA)
  } else if (type == "txt"){
    out <- x
  } else if (type == "stan"){
    out <- x
  } else {
    stop(type, " not implemented.")
  }

  writeLines(text = out, con = fp)

  if(zip){
    zip(files = fp, zipfile = zfp, flags = "-jq")
    file.remove(fp)
  }
  return(invisible(TRUE))
}

#' @rdname write_to_path
#' @keywords internal
write_json_to_path <- function(x, path, pdb, type, name = NULL, zip = FALSE, info = TRUE, overwrite = FALSE){
  write_to_path(x, path, pdb, type = "json", name, zip, info, overwrite)
}
#' @rdname write_to_path
#' @keywords internal
write_txt_to_path <- function(x, path, pdb, type, name = NULL, zip = FALSE, info = TRUE, overwrite = FALSE){
  write_to_path(x, path, pdb, type = "txt", name, zip, info, overwrite)
}
#' @rdname write_to_path
#' @keywords internal
write_stan_to_path <- function(x, path, pdb, type, name = NULL, zip = FALSE, info = TRUE, overwrite = FALSE){
  write_to_path(x, path, pdb, type = "stan", name, zip, info, overwrite)
}
