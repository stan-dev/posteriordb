#' Get all existing alias names from a posterior database
#'
#' @param pdb a \code{pdb} object.
#' @param type type of alias names. Cureently only posteriors.
#' @param ... Further argument to methods.
#'
#' @export
alias_names <- function(type, pdb = pdb_default()){
  names(pdb_aliases(type, pdb))
}

#' Extract aliases list from posterior database
#'
#' @inheritParams alias_names
#'
pdb_aliases <- function(type, pdb){
  checkmate::assert_choice(type, supported_alias_types())
  a <- read_json_from_pdb(paste0(type, ".json"), path = "alias", pdb)
  class(a) <- c(paste0("pdb_",type,"_aliases"), paste0("pdb_aliases"))
  assert_pdb_aliases(a)
  a
}

#' Return the name that the alias points to
#'
#' @inheritParams alias_names
#' @param x a name to lookup in alias list
#'
handle_aliases <- function(x, type, pdb){
  checkmate::assert_string(x)
  checkmate::assert_choice(type, supported_alias_types())
  checkmate::assert_class(pdb, "pdb")

  a <- pdb_aliases(type, pdb)
  nm <- a[[x]]
  if(is.null(nm)) nm <- x

  return(nm)
}

assert_pdb_aliases <- function(x){
  checkmate::assert_class(x, "pdb_aliases")
  checkmate::assert_named(x)
}

supported_alias_types <- function() c("posteriors")
