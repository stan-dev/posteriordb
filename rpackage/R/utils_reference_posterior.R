#' Check that reference posterior draws follows the
#' reference posterior definition.
#'
#' @param x a posterior name, posterior object or reference_posterior_draws object
#' @param ... currently not used.
#'
#' @export
check_reference_posterior_draws <- function(x, ...){
  UseMethod("check_reference_posterior_draws")
}

#' @rdname check_reference_posterior_draws
#' @export
check_reference_posterior_draws.character <- function(x, ...){
  x <- reference_posterior_draws(x)
  check_reference_posterior_draws(x)
}

#' @rdname check_reference_posterior_draws
#' @export
check_reference_posterior_draws.pdb_posterior <- function(x, ...){
  x <- reference_posterior_draws(x)
  check_reference_posterior_draws(x)
}

#' @rdname check_reference_posterior_draws
#' @export
check_reference_posterior_draws.pdb_reference_posterior_draws <- function(x, ...){
  assert_reference_posterior_draws(x)
  rpi <- info(x)
  assert_reference_posterior_info(rpi)

  tst <- list()

  # Assert that there is exactly 10000 draws
  checkmate::assert_true(rpi$diagnostics$ndraws == 10000)
  tst$ndraws_is_10k <- TRUE

  # Assert the effective sample size is correct/within bounds
  ess_bnds <- ess_bounds(x)
  checkmate::assert_numeric(rpi$diagnostics$effective_sample_size_bulk, lower = ess_bnds$ess_bulk[2], upper = ess_bnds$ess_bulk[1])
  checkmate::assert_numeric(rpi$diagnostics$effective_sample_size_tail, lower = ess_bnds$ess_tail[2], upper = ess_bnds$ess_tail[1])
  tst$ess_within_bounds <- TRUE

  # Assert all Rhat < 1.01
  checkmate::assert_numeric(rpi$diagnostics$r_hat, upper = 1.01)
  tst$r_hat_below_1_01 <- TRUE

  # Assert that the EFMI is larger than 0.2
  checkmate::assert_numeric(rpi$diagnostics$expected_fraction_of_missing_information, lower = 0.2)
  tst$efmi_above_0_2 <- TRUE

  # Add checks made to reference posterior
  rpi$checks_made <- tst

  # Add the rp information
  assert_reference_posterior_info(rpi)
  attr(x, "info") <- rpi

  # Check the reference posterior
  assert_reference_posterior_draws(x)
  invisible(x)
}

#' Compute ESS tail and bulk bounds
#'
#' @details Compute the bounds for ESS tail and bulk based on 100 000
#' simulated ESS computations.
#'
#' @param x a [pdb_reference_posterior_draws] object.
#' @param p the joint probability for independent ESS estimators.
#' @keywords internal
ess_bounds <- function(x){
  checkmate::assert_class(x, "draws")

  npar <- posterior::nvariables(x)
  ndraws <- posterior::ndraws(x)
  # We approximate ESS SD as follows (after some simulations)
  # We then use 4 SD to check the ESSs
  approx_ess_sd <- sqrt(7) * sqrt(ndraws)
  bnds <- ndraws + 4 * c(approx_ess_sd, -approx_ess_sd)

  #  alpha <- 1 - exp(log(p)/npar)
  #  essb <- esst <- NULL # To mask check NOTEs

  list(ess_bulk = bnds,
       ess_tail = bnds)

}

#' Thin draws objects to reduce their size and autocorrelation of the chains.
#'
#' @description Thin [pdb_reference_posterior_draws] objects to reduce their size and autocorrelation of the chains.
#'
#' @param x An R object for which the methods are defined.
#' @param thin A positive integer specifying the period for selecting draws.
#' @param ... Arguments passed to individual methods (if applicable).
#'
#' @return
#' A thinned [pdb_reference_posterior_draws] object.
#'
#' @export
thin_draws.pdb_reference_posterior_draws <- function(x, thin, ...){
  x$draws <- posterior::thin_draws(x$draws, thin, ...)
  checkmate::assert_class(x, "pdb_reference_posterior_draws")
  x
}
