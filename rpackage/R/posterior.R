#' Access a posterior in the posterior database
#'
#' @param name a posterior name that exist in the posterior database
#' @param pdb a \code{pdb} posterior database object.
#' @export
posterior <- function(name, pdb = pdb()) {
  checkmate::assert_string(name)
  checkmate::assert_class(pdb, "pdb")
  po <- read_info_json(name, "posteriors", pdb)
  po$pdb <- pdb
  class(po) <- "pdb_posterior"
  po$model_info <- read_model_info(po)
  po$data_info <- read_data_info(po)
  assert_pdb_posterior(po)
  po
}
#' @rdname posterior
#' @export
pdb_posterior <- posterior

# read a posterior object from the data base
read_posterior_info <- function(pdb, name, ...) {
  pfn <- pdb_cached_local_file_path(pdb, path = file.path("posteriors", paste0(name, ".json")))
  po <- jsonlite::read_json(pfn)
  po$name <- name
  po$pdb <- pdb
  po$added_date <- as.Date(po$added_date)
  class(po) <- "pdb_posterior_info"
  po
}

#' @export
print.pdb_posterior <- function(x, ...) {
  cat0("Posterior\n\n")
  print(x$data_info)
  cat0("\n")
  print(x$model_info)
  invisible(x)
}

assert_pdb_posterior <- function(x) {
  checkmate::assert_class(x, "pdb_posterior")
  checkmate::assert_list(x)
  must.include <- c(
    "model_name", "data_name", "model_info", "data_info", "name",
    "pdb", "added_by", "added_date"
  )
  checkmate::assert_names(names(x), must.include = must.include)
  checkmate::assert_class(x$added_date, "Date")
  checkmate::assert_class(x$data_info$added_date, "Date")
  checkmate::assert_class(x$model_info$added_date, "Date")
  checkmate::assert_list(x$model_info, min.len = 1)
  invisible(x)
}
