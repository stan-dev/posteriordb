#' Create Posterior Database tibbles
#'
#' @details Generates a tibble data frame of all posteriors
#' in the database and their side information
#'
#' @param pdb a \code{pdb} object.
#' @param ... further arguments to supply to \code{dplyr::filter()}
#' @export
posteriors_tbl_df <- function(pdb = pdb_default(), ...){
  pdb_tibble(pdb, path = "posteriors")
}

models_tbl_df <- function(pdb = pdb_default(), ...){
  pdb_tibble(pdb, path = "models/info")
}

data_tbl_df <- function(pdb = pdb_default(), ...){
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
    x <- read_info_json(fnms[i], path = path, pdb = pdb)
    obj_list[[i]] <- as.data.frame(x)
  }
  dat <- do.call(rbind, obj_list)
  dplyr::as.tbl(dat)
}


#' Coerce a [pdb_posterior] to a Data Frame
#'
#' @details The dataframe will consist of one row per keyword.
#'
#' @param x a [pdb_posterior] object.
#' @param row.names NULL or a character vector giving the row names for the data frame. Missing values are not allowed.
#' @param ... further arguments to \code{as.data.frame} for a list.
#' @param optional Not used.
#' @export
as.data.frame.pdb_posterior <- function(x, row.names = NULL, optional = FALSE, ...){
  kws <- unlist(x$keywords)
  elements <- c("name", "model_name", "gold_standard_name", "data_name", "added_by", "added_date")
  if(is.null(x$gold_standard_name)) x$gold_standard_name <- "NULL"
  df <- as.data.frame(x[elements], stringsAsFactors = FALSE, ...)[rep(1, max(1,length(kws))), ]
  if(length(kws) == 0){
    df$keywords <- ""
  } else {
    df$keywords <- kws
  }
  rownames(df) <- row.names
  df
}
#' @rdname as.data.frame.pdb_posterior
#' @export
as.data.frame.pdb_posteriors <- as.data.frame.pdb_posterior
