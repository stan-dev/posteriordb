#' Check a posterior database
#' @noRd
#' @param pdb a \code{pdb} object
#' @param posterior_idx an index vector indicating what posteriors to check.
#' @return a boolean indicating if the pdb works as it should.
check_pdb <- function(pdb, posterior_idx = NULL) {
  checkmate::assert_class(pdb, "pdb")
  message("Checking posterior database...")
  pns <- names(pdb)
  if(!is.null(posterior_idx)) pns <- pns[posterior_idx]
  pl <- list()
  for (i in seq_along(pns)) {
    pl[[i]] <- posterior(name = pns[i], pdb = pdb)
  }
  message("1. All posteriors can be read.")
  for (i in seq_along(pl)) {
    model_info(pl[[i]])
    stan_code(pl[[i]])
  }
  message("2. All stan_code can be read.")
  for (i in seq_along(pl)) {
    data_info(x = pl[[i]])
    stan_data(x = pl[[i]])
  }
  message("3. All stan_data can be read.")
  for (i in seq_along(pl)) {
    if(is.null(pl[[i]]$reference_posterior_name)) next
    reference_posterior_info(x = pl[[i]])
    reference_posterior_draws(x = pl[[i]])
  }
  message("4. All reference_posteriors can be read.")
  message("Posterior database is ok.\n")
  invisible(TRUE)
}
