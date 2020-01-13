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

  # pdb_diagnostics(stan_object)

  rpd <- reference_posterior_draws(x = stan_object, info = rpi)

  # Subset to relevant prameters
  rpd <- subset(rpd, variable = names(po$dimensions))

  rpd
}


#' @rdname reference_posterior_draws
#' @export
reference_posterior_draws.stanfit <- function(x, info, pdb = pdb_default(), ...){
  checkmate::assert_class(info, "pdb_reference_posterior_info")
  draws <- posterior::as_draws_list(posterior::as_draws(x))
  names(draws) <- NULL
  for(i in seq_along(draws)){
    draws[[i]]$lp__ <- NULL
  }
  attr(draws, "name") <- x@model_name
  attr(draws, "info") <- info
  class(draws) <- c("pdb_reference_posterior_draws", class(draws))
  assert_reference_posterior_draws(draws)
  draws
}
