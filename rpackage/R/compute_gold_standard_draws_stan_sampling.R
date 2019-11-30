#' Compute a Gold Standard using Rstan
#'
#' @param gsi a [gold_standard_info] object.
#' @param pdb a [pdb] object.
#'
#' @keywords internal
#' @noRd
compute_gold_standard_draws_stan_sampling <- function(gsi, pdb){
  checkmate::assert_class(pdb, "pdb_local")
  assert_gold_standard_info(gsi)
  po <- posterior(name = gsi$name, pdb = pdb)

  stan_args <- list(model_name = gsi$name,
                    model_code = stan_code(po),
                    data = stan_data(po))
  stan_args <- c(stan_args, gsi$inference_method_arguments)
  stan_object <- do.call(rstan::stan, stan_args)

  # Stan model codes are stored locally (seem to be a bug)
  stan_object@model_name <- gsi$name

  gsd <- gold_standard_draws(x = stan_object)

  # Subset to relevant prameters
  gsd <- subset(gsd, variable = names(po$dimensions))

  gsd
}


#' @rdname gold_standard_draws
#' @export
gold_standard_draws.stanfit <- function(x, pdb = pdb_default(), ...){
  x <- list(name = x@model_name,
            draws = posterior::as_draws_list(posterior::as_draws(x)))
  names(x$draws) <- NULL
  for(i in seq_along(x$draws)){
    x$draws[[i]]$lp__ <- NULL
  }
  class(x) <- c("pdb_gold_standard_draws", class(x))
  assert_gold_standard_draws(x)
  x
}
