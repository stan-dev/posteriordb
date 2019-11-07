#' Filter Posteriors in Database
#'
#' @details
#' Filter posteriors in the database and return list of
#' posteriors/models/data to work with as a list.
#'
#' The function is built upon the dplyr filter function and
#' follows the exact same syntax. All elements in the
#' `posteriors/[posterior_name].json`, `models/info/[model_name].json`
#' and `data/info/[data_name].json` can be used to filter the
#' posterior database. See examples below.
#'
#' @param pdb a \code{pdb} object.
#' @param ... further arguments to supply to \code{dplyr::filter()}
#' @export
filter_posteriors <- function(pdb, ...){
  pdb_filter(pdb, path = "posteriors", ...)
}

#' Internal filter function
#'
#' Works for filtering models, data and posteriors.
#'
#' @keywords internal
#' @param pdb a pdb connection
pdb_filter <- function(pdb, path, ...){
  checkmate::assert_class(pdb, "pdb")
  checkmate::assert_choice(path, c("posteriors", "models/info", "data/info"))

  dat <- pdb_tibble(pdb, path)

  dat_tbl <- dplyr::filter(dat, ...)

  nms <- unique(dat_tbl$name)
  obj_list <- list()
  for(i in seq_along(nms)) {
    obj_list[[i]] <- posterior(name = nms[i], pdb = pdb)
  }
  obj_list
}
