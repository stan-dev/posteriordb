#' Compute a Reference Posteriors using Rstan
#'
#' @param rpi a [reference_posterior_info] object.
#' @param pdb a [pdb] object.
#'
#' @keywords internal
#' @noRd
compute_reference_posterior_draws_stan_sampling <- function(rpi, pdb){
  checkmate::assert_class(pdb, "pdb_local")
  assert_reference_posterior_info(x = rpi)
  po <- posterior(name = rpi$name, pdb = pdb)

  stan_args <- list(model_name = rpi$name,
                    model_code = stan_code(po),
                    data = stan_data(po))
  stan_args <- c(stan_args, rpi$inference$method_arguments)
  stan_object <- do.call(rstan::stan, stan_args)

  # Stan model codes are stored locally (seem to be a bug)
  stan_object@model_name <- rpi$name

  gsd <- reference_posterior_draws(x = stan_object)

  # Subset to relevant prameters
  gsd <- subset(gsd, variable = names(po$dimensions))

  gsd
}


#' @rdname reference_posterior_draws
#' @export
reference_posterior_draws.stanfit <- function(x, pdb = pdb_default(), ...){
  x <- list(name = x@model_name,
            draws = posterior::as_draws_list(posterior::as_draws(x)))
  names(x$draws) <- NULL
  for(i in seq_along(x$draws)){
    x$draws[[i]]$lp__ <- NULL
  }
  class(x) <- c("pdb_reference_posterior_draws", class(x))
  assert_reference_posterior_draws(x)
  x
}
