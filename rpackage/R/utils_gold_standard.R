#' Test that gold standard draws follows the
#' gold standard definition.
#'
#' @param x a posterior name, posterior object or gold_standard_draws object
#' @param ... currently not used.
#'
#' @export
test_gold_standard_draws <- function(x, ...){
  UseMethod("test_gold_standard_draws")
}

#' @rdname test_gold_standard_draws
#' @export
test_gold_standard_draws.character <- function(x, ...){
  x <- gold_standard_draws(x)
  test_gold_standard_draws(x)
}

#' @rdname test_gold_standard_draws
#' @export
test_gold_standard_draws.pdb_posterior <- function(x, ...){
  x <- gold_standard_draws(x)
  test_gold_standard_draws(x)
}

#' @rdname test_gold_standard_draws
#' @export
test_gold_standard_draws.pdb_gold_standard_draws <- function(x, ...){
  # Assert that there is exactly 10000 draws
  checkmate::assert_true(posterior::ndraws(x$draws) == 10000)
  pds <- posterior::summarise_draws(x$draws)

  # Assert the effective sample size is correct
  ess_bnds <- ess_bounds(x$draws)
  checkmate::assert_numeric(pds$ess_bulk, lower = ess_bnds$ess_bulk[1], upper = ess_bnds$ess_bulk[2])
  checkmate::assert_numeric(pds$ess_tail, lower = ess_bnds$ess_tail[1], upper = ess_bnds$ess_tail[2])

  # Assert all Rhat < 1.01
  checkmate::assert_numeric(pds$rhat, upper = 1.01)

  invisible(x)
}


#' Compute a Gold Standard using Rstan
#'
#' @param gsi a [gold_standard_info] object.
#' @param pdb a [pdb] object.
#'
#' @keywords internal
#' @noRd
compute_gold_standard_draws_stan_sampling <- function(gsi, pdb){
  checkmate::assert_class(pdb, "pdb")
  assert_gold_standard_info(gsi)
  po <- posterior(name = gsi$name, pdb = pdb)

  stan_args <- list(model_name = gsi$name,
                    model_code = stan_code(po),
                    data = stan_data(po))
  stan_args <- c(stan_args, gsi$inference_method_arguments)
  stan_object <- do.call(rstan::stan, stan_args)

  gsd <- gold_standard_draws(x = stan_object)

  # Subset to relevant prameters
  gsd <- subset(gsd, variable = names(po$dimensions))

  gsd
}

#' Compute ESS tail and bulk bounds
#'
#' @details Compute the bounds for ESS tail and bulk based on 100 000
#' simulated ESS computations.
#'
#' @param x a [pdb_gold_standard_draws] object.
#' @param p the joint probability for independent ESS estimators.
#' @keywords internal
ess_bounds <- function(x, p = 0.95){
  checkmate::assert_class(x, "draws")
  npar <- posterior::nvariables(x)
  alpha <- 1 - exp(log(p)/npar)
  essb <- esst <- NULL # To mask check NOTEs
  utils::data("essb", package = "posteriordb", envir = environment())
  utils::data("esst", package = "posteriordb", envir = environment())
  list(ess_bulk = unname(stats::quantile(essb, c(alpha/2, 1-alpha/2))),
       ess_tail = unname(stats::quantile(esst, c(alpha/2, 1-alpha/2))))
}
