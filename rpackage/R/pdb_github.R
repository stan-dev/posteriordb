#' @rdname pdb_local
#' @export
pdb_github <- function(repo = getOption("pdb_repo", "stan-dev/posteriordb/posterior_database"),
                       cache_path = tempdir(),
                       ref = github_ref(),
                       subdir = NULL,
                       auth_token = github_pat(),
                       host = "https://api.github.com"){
  pdb(x = repo, pdb_type = "github", cache_path = cache_path, ref = ref, subdir = subdir, pat = auth_token, host = host)
}

#' Setup a GitHub pdb
#' @noRd
#' @param pdb a github pdb to setup
#' @param ref see \code{pdb_github}.
#' @param subdir see \code{pdb_github}.
#' @param pat see \code{pdb_github}.
#' @param host see \code{pdb_github}.
setup_pdb.pdb_github <- function(pdb, ...){
  arg <- list(...)
  pdb$github <- remotes::parse_github_repo_spec(pdb$pdb_id)
  if(!nzchar(pdb$github$ref)) {
    pdb$github$ref <- arg$ref
  }
  if(!nzchar(pdb$github$subdir)) {
    pdb$github$subdir <- arg$subdir
  }
  pdb$github$host <- arg$host
  pdb$github$pat <- arg$pat

  pdb <- pdb_endpoint(pdb)
  pdb
}

#' @rdname pdb_version
#' @export
pdb_version.pdb_github <- function(pdb, ...){
  pat <- github_pat(pdb)
  ghp <- gh::gh(github_path(pdb, type = "git/ref/heads"), .token = pat)
  list("sha" = ghp$object$sha)
}

pn.pdb_github <- function(pdb, ...) {
  pns <- github_dir(gh_path = github_path(pdb, type = "contents", path = "posteriors"), pdb = pdb)
  remove_file_extension(pns)
}

#' @rdname pdb_file_copy
pdb_file_copy.pdb_github <- function(pdb, from, to, overwrite = FALSE, ...){
  pat <- github_pat(pdb)
  ghp <- gh::gh(github_path(pdb, type = "contents", path = from), .token = pat)

  if(is.null(pat)) {
    ret <- httr::GET(ghp$download_url, httr::write_disk(to, overwrite = overwrite))
  } else {
    ret <- httr::GET(ghp$download_url, httr::add_headers(c("Authorization" = paste0("token ", pat))), httr::write_disk(to, overwrite = overwrite))
  }

  httr::status_code(ret) == 200L
}


#' @rdname data_names
#' @export
data_names.pdb_github <- function(pdb, ...) {
  pns <- github_dir(gh_path = github_path(pdb, type = "contents", path = "data/info"), pdb = pdb)
  pns <- pns[grepl(pns, pattern = "\\.json")]
  basename(remove_file_extension(pns))
}

#' @rdname data_names
#' @export
model_names.pdb_github <- function(pdb, ...) {
  pns <- github_dir(gh_path = github_path(pdb, type = "contents", path = "models/info"), pdb = pdb)
  pns <- pns[grepl(pns, pattern = "\\.json")]
  basename(remove_file_extension(pns))
}

#' @rdname data_names
#' @export
reference_posterior_names.pdb_github <- function(pdb, ...) {
  pns <- github_dir(gh_path = github_path(pdb, type = "contents", path = "reference_posteriors/draws/info"), pdb = pdb)
  pns <- pns[grepl(pns, pattern = "\\.json")]
  basename(remove_file_extension(pns))
}


#' @noRd
#' @rdname pdb_endpoint
#' @keywords internal
pdb_endpoint.pdb_github <- function(pdb, ...) {
  if(!is_pdb_endpoint(pdb)){
    stop2("No posterior database in '", pdb$pdb_id, "'.")
  }
  pdb
}

#' @noRd
#' @rdname is_pdb_endpoint
#' @keywords internal
is_pdb_endpoint.pdb_github <- function(pdb, ...) {
  dir_github <- github_dir(github_path(pdb, type = "contents"), pdb)
  all(pdb_minimum_contents() %in% dir_github)
}

github_dir <- function(gh_path, pdb, recursive = FALSE, full.names = TRUE, ...){
  if(recursive) stop("not implemented")
  if(!full.names) stop("not implemented")
  checkmate::assert_class(pdb, c("pdb_github"))
  x <- gh::gh(gh_path, .token = github_pat(pdb), ...)
  unlist(lapply(x, FUN=function(x) x$name))
}

github_path <- function(pdb, type, path = NULL){
  checkmate::assert_class(pdb, c("pdb_github"))
  checkmate::assert_choice(type, c("contents", "git/ref/heads"))
  base_path <- file.path("/repos", pdb$github$username, pdb$github$repo)

  if(type == "contents"){
    final_path <- paste0(file.path0(base_path, "contents", pdb$github$subdir, path), "?ref=", pdb$github$ref)
    return(final_path)
  } else if (type == "git/ref/heads"){
    final_path <- file.path0(base_path, "git/ref/heads", pdb$github$ref)
    return(final_path)
  }

  stop("Incorrect type argument. This should not happen.")
}


#' Retrieve Github personal access token.
#'
#' A github personal access token
#' Looks in env var `GITHUB_PAT`
#' @param pdb A posterior datasbase object to extract pat from.
#' @export
github_pat <- function(pdb = NULL) {
  # Sys.setenv(GITHUB_PAT = "my github token here")
  # Sys.unsetenv("GITHUB_PAT")
  pat <- Sys.getenv("GITHUB_PAT")
  if (nzchar(pat)) {
    return(pat)
  }
  if(is.null(pdb)) return(NULL)
  pdb$github$pat
}

#' Retrieve Github reference.
#'
#' A github reference to use
#' Looks in env var `GITHUB_REF`
#' @param pdb A posterior datasbase object.
#' @export
github_ref <- function(pdb = NULL) {
  ref <- Sys.getenv("GITHUB_REF")
  if (nzchar(ref)) {
    # This is to handle that GITHUB_REF on Github Actions return 'refs/heads/[ref]'
    ref <- sub("^refs/heads/", "", ref)
    return(ref)
  } else {
    return("master")
  }
}



#' Download file from GitHub
#'
#' A github personal access token
#' Looks in env var `GITHUB_PAT`
#' @param download_url A github download url
#' @param to A local file path to download to
#' @param pat A github access token
#' @param overwrite Should an existing file be overwritten?
#' @keywords internal
#' @noRd
github_download <- function(download_url, to, pat, overwrite){
  checkmate::assert_string(download_url, pattern = "^http(s)?://")
  checkmate::assert_path_for_output(to, overwrite = TRUE)
  checkmate::assert_string(pat, null.ok = TRUE)
  checkmate::assert_flag(overwrite)

  if(file.exists(to) & !overwrite) return(TRUE)

  if(is.null(pat)) {
    ret <- httr::GET(download_url, httr::write_disk(to, overwrite = overwrite))
  } else {
    ret <- httr::GET(download_url, httr::add_headers(c("Authorization" = paste0("token ", pat))), httr::write_disk(to, overwrite = overwrite))
  }
  httr::http_error(ret)
  httr::status_code(ret) == 200L
}


#' @noRd
#' @rdname pdb_cache_dir
#' @keywords internal
pdb_cache_dir.pdb_github <- function(pdb, path, ...){
  pat <- github_pat(pdb)
  ghp <- gh::gh(github_path(pdb, type = "contents", path = path), .token = pat)
  download_urls <- unlist(lapply(ghp, FUN = function(x) x$download_url))
  fns <- unlist(lapply(ghp, FUN = function(x) x$name))
  message("Downloading github content...")
  for(i in seq_along(download_urls)){
    to <- pdb_cache_path(pdb = pdb, path = file.path(path, fns[i]))
    github_download(download_url = download_urls[i], to = to, pat = pat, overwrite = FALSE)
  }
  message("Done.")
}
