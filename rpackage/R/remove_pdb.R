#' Remove objects from local pdb
#'
#' @description a function to simplify writing to a local pdb.
#'
#' @param x an object name to remove to the pdb.
#' @param type Type of object to remove.
#' @param pdb the pdb to remove from. Only a local pdb.
remove_from_pdb <- function(x, type, pdb){
  checkmate::assert_class(pdb, "pdb_local")
  checkmate::assert_character(x)
  checkmate::assert_choice(type, c("posteriors", "models", "data", "reference_posteriors"))
  eval(parse(paste0("remove_", type, "_from_pdb(x, pdb, ...)")))
}

#' @rdname remove_from_pdb
remove_posteriors_from_pdb <- function(x, pdb){
  fp <- paste0(file.path(pdb_endpoint(pdb), "posteriors", x), ".json")
  checkmate::assert_file_exists(fp)
  file.remove(fp)
}

#' @rdname remove_from_pdb
remove_data_from_pdb <- function(x, pdb){
  fp1 <- paste0(file.path(pdb_endpoint(pdb), "data", "data", x), ".json.zip")
  fp2 <- paste0(file.path(pdb_endpoint(pdb), "data", "info", x), ".info.json")
  checkmate::assert_file_exists(c(fp1, fp2))
  file.remove(c(fp1, fp2))
}

#' @rdname remove_from_pdb
remove_models_from_pdb <- function(x, pdb){
  fp1 <- paste0(file.path(pdb_endpoint(pdb), "models", "info", x), ".info.json")
  fp2 <- paste0(file.path(pdb_endpoint(pdb), "models", "stan", x), ".stan")
  file.remove(c(fp1, fp2))
}

#' @rdname remove_from_pdb
remove_reference_posterior_from_pdb <- function(x, pdb){
  fp1 <- paste0(file.path(pdb_endpoint(pdb), "reference_posteriors", "info", x), ".info.json")
  fp2 <- paste0(file.path(pdb_endpoint(pdb), "reference_posteriors", "draws", x), ".json.zip")
  checkmate::assert_file_exists(c(fp1, fp2))
  file.remove(c(fp1, fp2))
}
