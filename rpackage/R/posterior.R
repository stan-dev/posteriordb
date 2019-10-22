#' Access a posterior in the posterior database
#'
#' @param name a posterior name that exist in the posterior database
#' @param pdb a \code{pdb} posterior database object.
#' @export
posterior <- function(name, pdb = pdb()) {
  po <- read_posterior(name, pdb)
  po$model_info <- read_model_info(po)
  po$data_info <- read_data_info(po)
  po$added_date <- as.Date(po$added_date)
  assert_pdb_posterior(po)
  po
}
#' @rdname posterior
#' @export
pdb_posterior <- posterior

#' read a posterior object from the data base
read_posterior <- function(name, pdb) {
  checkmate::assert_class(pdb, "pdb")
  checkmate::assert_character(name)
  checkmate::assert_choice(name, names(pdb))
  pfn <- posterior_file_path(name, pdb)
  po <- jsonlite::read_json(pfn)
  po$name <- name
  po$pdb <- pdb
  class(po) <- "pdb_posterior"
  po
}
#' @rdname read_posterior
#' @export
read_pdb_posterior <- read_posterior

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

posterior_file_path <- function(x, ...) {
  UseMethod("posterior_file_path")
}

#' @export
posterior_file_path.character <- function(x, pdb, ...) {
  checkmate::assert_choice(x, names(pdb))
  checkmate::assert_class(pdb, "pdb")
  file.path(pdb$path, "posteriors", paste0(x, ".json"))
}

#' @export
posterior_file_path.pdb_posterior <- function(x, ...) {
  file.path(x$pdb$path, "posteriors", paste0(x$name, ".json"))
}
