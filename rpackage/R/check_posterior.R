#' Test a posterior
#'
#' @details
#' The function checks a posterior is consistent.
#'
#' @param po a [pdb_posterior] to check.
#'
#' @export
check_posterior <- function(po, run_stan_code_checks = TRUE) {
  checkmate::assert_class(po, "pdb_posterior")

  message("Checking posterior '", po$name,"' ...")

  po <- pdb_posterior(po$name, pdb = pdb(po))
  message("- Posterior can be read.")

  check_pdb_read_model_code(list(po))
  message("- The model_code can be read.")

  posteriordb:::check_pdb_read_data(list(po))
  message("- The data can be read.")

  posteriordb:::check_pdb_read_reference_posterior_draws(list(po))
  message("- The reference_posteriors_draws can be read (if it exists).")

  check_pdb_aliases(pdb(po))
  message("- Aliases are ok.")

  if(run_stan_code_checks){
    check_posterior_stan_syntax(po)
    message("- Stan syntax is ok.")

    check_pdb_run_stan(po)
    message("- Stan can be run for the posterior.")
  }

  suppressMessages(check_pdb_references(pdb(po)))
  message("- References and bibliography are ok.")

  message("\nPosterior is ok.\n")
  invisible(TRUE)
}
