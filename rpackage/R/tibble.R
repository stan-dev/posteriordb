#' Create Posterior Database tibbles
#'
#' @details Generates a tibble data frame of all posteriors
#' in the database and their side information
#'
#' @param pdb a \code{pdb} object.
#' @param ... further arguments to supply to \code{dplyr::filter()}
#' @export
pdb_tibble_posteriors <- function(pdb, ...){
  pdb_tibble(pdb, path = "posteriors")
}

pdb_tibble_models <- function(pdb, ...){
  pdb_tibble(pdb, path = "models/info")
}

pdb_tibble_data <- function(pdb, ...){
  pdb_tibble(pdb, path = "data/info")
}

#' @noRd
#' @keywords internal
pdb_tibble <- function(pdb, path, ...){
  checkmate::assert_class(pdb, "pdb")
  checkmate::assert_choice(path, c("posteriors", "models/info", "data/info"))

  pdb_cache_dir(pdb, path)
  fnms <- pdb_list_files_in_cache(pdb, path, file_ext = FALSE)

  obj_list <- list()
  for(i in seq_along(fnms)) {
    obj_list[[i]] <- as.data.frame(read_info_json(fnms[i], path = path, pdb = pdb))
  }
  dat <- do.call(rbind, obj_list)
  dplyr::as.tbl(dat)
}
