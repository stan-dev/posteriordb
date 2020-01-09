#' Test that gold standard draws follows the
#' gold standard definition.
#'
#' @param x a posterior name, posterior object or reference_posterior_draws object
#' @param ... currently not used.
#'
#' @export
test_reference_posterior_draws <- function(x, n = 10000, ...){
  UseMethod("test_reference_posterior_draws")
}

#' @rdname test_reference_posterior_draws
#' @export
test_reference_posterior_draws.character <- function(x, n = 10000, ...){
  x <- reference_posterior_draws(x)
  test_reference_posterior_draws(x)
}

#' @rdname test_reference_posterior_draws
#' @export
test_reference_posterior_draws.pdb_posterior <- function(x, n = 10000, ...){
  x <- reference_posterior_draws(x)
  test_reference_posterior_draws(x)
}

#' @rdname test_reference_posterior_draws
#' @export
test_reference_posterior_draws.pdb_reference_posterior_draws <- function(x, n = 10000, ...){
  # Assert that there is exactly 10000 draws
  checkmate::assert_true(posterior::ndraws(x$draws) == n)
  pds <- posterior::summarise_draws(x$draws)

  # Assert the effective sample size is correct/within bounds
  ess_bnds <- ess_bounds(x$draws)
  checkmate::assert_numeric(pds$ess_bulk, lower = ess_bnds$ess_bulk[1], upper = ess_bnds$ess_bulk[2])
  checkmate::assert_numeric(pds$ess_tail, lower = ess_bnds$ess_tail[1], upper = ess_bnds$ess_tail[2])

  # Assert all Rhat < 1.01
  checkmate::assert_numeric(pds$rhat, upper = 1.01)

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
  approx_ess_sd <- sqrt(7) * sqrt(ndraws)
#  alpha <- 1 - exp(log(p)/npar)
#  essb <- esst <- NULL # To mask check NOTEs
  bnds <- ndraws + 4 * c(approx_ess_sd, -approx_ess_sd)

  list(ess_bulk = bnds,
       ess_tail = bnds)
#  list(ess_bulk = unname(stats::quantile(essb, c(alpha/2, 1-alpha/2))),
#       ess_tail = unname(stats::quantile(esst, c(alpha/2, 1-alpha/2))))
}


thin_draws.pdb_reference_posterior_draws <- function(x, thin, ...){
  rpd
}

rpd$draws
