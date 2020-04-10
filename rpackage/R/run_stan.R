#' Run Stan on a posterior
#'
#' @description
#' Run Stan on a posterior
#'
#' @param x a [pdb_posterior] object.
#' @param stan_args Arguments supplied to [rstan::stan] to compute the posterior
#'
run_stan <- function(x, stan_args, ...){
  UseMethod("run_stan")
}

#' @rdname run_stan
run_stan.pdb_posterior <- function(x, stan_args, ...){
  checkmate::assert_list(stan_args)
  checkmate::assert_names(names(stan_args), disjunct.from = c("model_name", "model_code", "data"))
  sa <- list(model_name = x$name,
             model_code = stan_code(x),
             data = stan_data(x))
  sa <- c(sa, stan_args)
  stan_object <- do.call(rstan::stan, sa)

  # Stan model codes are stored locally (seem to be a bug)
  stan_object@model_name <- rpi$name
  stan_object
}
