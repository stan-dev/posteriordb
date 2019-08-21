#' Check a posterior database
#' @noRd
#' @param pdbo a \code{pdb} object
#' @return a boolean indicating if the pdb works as it should.
check_pdb <- function(pdbo){
  checkmate::assert_class(pdbo, "pdb")
  message("Checking posterior database...")
  pns <- names(pdbo)
  pl <- list()
  for(i in seq_along(pns)){
    pl[[i]] <- posterior(pns[i], pdbo = pdbo)
  }
  message("1. All posteriors can be read.")
  for(i in seq_along(pl)){
    stan_code(pl[[i]])
  }
  message("2. All stan_code can be read.")
  for(i in seq_along(pl)){
    stan_data(x = pl[[i]])
  }
  message("3. All stan_data can be read.")
  message("Posterior database is ok.\n")
  return(invisible(TRUE))
}
