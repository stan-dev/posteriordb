
#' Remove objects from local pdb
#'
#' @description a function to simplify removing object from a local pdb.
#'
#' @param x an object to remove to the pdb.
#' @param pdb the pdb to remove from. Currently only a local pdb.
#' @param type supported reference posterior types.
#' @param remove_info should the information JSON be removed as well?
#' @param ... further arguments supplied to methods.
#'
#' @export
remove_pdb <- function(x, pdb, ...){
  checkmate::assert_class(pdb, "pdb_local")
  UseMethod("remove_pdb")
}

#' @rdname remove_pdb
#' @export
remove_pdb.character <- function(x, pdb, ...){
  checkmate::assert_file_exists(x)
  file.remove(x)
}

#' @rdname remove_pdb
#' @export
remove_pdb.pdb_data <- function(x, pdb, remove_info = TRUE,...){
  fn <- paste0(info(x)$name, ".json.zip")
  fp <- pdb_file_path(pdb, "data", "data", fn)
  remove_pdb(fp, pdb)
  if(remove_info) remove_pdb(info(x), pdb)
}

#' @rdname remove_pdb
#' @export
remove_pdb.pdb_data_info <- function(x, pdb, ...){
  fn <- paste0(x$name, ".info.json")
  fp <- pdb_file_path(pdb, "data", "info", fn)
  remove_pdb(fp, pdb)
}

#' @rdname remove_pdb
#' @export
remove_pdb.pdb_model_code <- function(x, pdb, remove_info = TRUE, ...){
  fw <- framework(x)
  fn <- paste0(info(x)$name, ".", fw)
  fp <- pdb_file_path(pdb, "models", fw, fn)
  remove_pdb(fp, pdb)
  if(remove_info) remove_pdb(info(x), pdb)
}

#' @rdname remove_pdb
#' @export
remove_pdb.pdb_model_info <- function(x, pdb, ...){
  fn <- paste0(x$name, ".info.json")
  fp <- pdb_file_path(pdb, "models", "info", fn)
  remove_pdb(fp, pdb)
}

#' @rdname remove_pdb
#' @export
remove_pdb.pdb_posterior <- function(x, pdb, ...){
  fn <- paste0(x$name, ".json")
  fp <- pdb_file_path(pdb, "posteriors", fn)
  remove_pdb(fp, pdb)
}

#' @rdname remove_pdb
#' @export
remove_pdb.pdb_reference_posterior_draws <- function(x, pdb, remove_info = TRUE, ...){
  fn <- paste0(info(x)$name, ".json.zip")
  fp <- pdb_file_path(pdb, "reference_posteriors", "draws", "draws", fn)
  remove_pdb(fp, pdb)
  if(remove_info) remove_pdb(info(x), type = "draws", pdb)
}

#' @rdname remove_pdb
#' @export
remove_pdb.pdb_reference_posterior_info <- function(x, pdb, type, ...){
  checkmate::assert_choice(type, choices = supported_reference_posterior_types())
  fn <- paste0(x$name, ".info.json")
  fp <- pdb_file_path(pdb, "reference_posteriors", type, "info", fn)
  remove_pdb(fp, pdb)
}
