#' Create a GitHub Posterior Database (pdb) connection
#'
#' @details
#' Connect to a posterior database in a github repo. The setup follows
#' that of the \code{remotes} R package.
#'
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
#' @export
pdb_github <- function(repo = getOption("pdb_repo", "MansMeg/posteriordb"),
                       cache_path = tempdir(),
                       ref = "master",
                       subdir = NULL,
                       auth_token = github_pat(),
                       host = "https://api.github.com"){
  pdb(pdb_id = repo, pdb_type = "github", cache_path = cache_path, ref = ref, subdir = subdir, pat = auth_token, host = host)
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

#' @export
posterior_names.pdb_github <- function(pdb) {
  pns <- github_dir(github_path(pdb, type = "contents", path = "posteriors"))
  remove_file_extension(pns)
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

#endpoint <- "/repos/MansMeg/posteriordb/contents?ref=github_pdb"

github_dir <- function(endpoint, pdb, ...){
  checkmate::assert_class(pdb, c("pdb_github"))
  x <- gh(endpoint, .token = github_pat(pdb), ...)
  unlist(lapply(x, FUN=function(x) x$name))
}

github_path <- function(pdb, type, path = NULL){
  checkmate::assert_class(pdb, c("pdb_github"))
  checkmate::assert_choice(type, c("contents"))
  base_path <- file.path("/repos", pdb$github$username, pdb$github$repo)

  if(type == "contents"){
    final_path <- paste0(file.path0(base_path, "contents", pdb$github$subdir, path), "?ref=", pdb$github$ref)
    return(final_path)
  }

  stop("Incorrect type argument. This should not happen.")
}


pdb_github_endpoint <- function(pdb){
  github_dir(github_path(pdb, "contents"))
}


#' Retrieve Github personal access token.
#'
#' A github personal access token
#' Looks in env var `GITHUB_PAT`
#' @param pdb A posterior datasbase object to extract pat from.
#' @keywords internal
#' @noRd
github_pat <- function(pdb = NULL) {
  pat <- Sys.getenv("GITHUB_PAT")
  if (nzchar(pat) > 1) {
    return(pat)
  }
  if(is.null(pdb)) return(NULL)
  pdb$github$pat
}





#' ---- OLD CAN BE REMOVED!

#' GET from github
#' @keywords internal
#' @noRd
github_GET <- function(host, path, pat){
  gh_url <- file.path(host, path)
  if(is.null(pat)) return(httr::GET(gh_url))
  httr::GET(gh_url, httr::add_headers(c("Authorization" = paste0("token ", pat))))
}
