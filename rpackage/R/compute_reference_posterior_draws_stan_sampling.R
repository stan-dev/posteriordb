#' Compute a Reference Posteriors for a reference posterior info object
#'
#' @param rpi a [reference_posterior_info] object.
#' @param pdb a [pdb] object.
#'
#' @export
compute_reference_posterior_draws <- function(rpi, pdb = pdb_default()){
  checkmate::assert_class(pdb, "pdb")
  assert_reference_posterior_info(x = rpi)
  if(rpi$inference$method == "stan_sampling"){
    rp <- compute_reference_posterior_draws_stan_sampling(rpi, pdb)
  } else {
    stop("Currently not implemented")
  }
  rp
}

#' Compute a Reference Posteriors using Rstan
#'
#' @param rpi a [reference_posterior_info] object.
#' @param pdb a [pdb] object.
#'
compute_reference_posterior_draws_stan_sampling <- function(rpi, pdb){
  checkmate::assert_class(pdb, "pdb")
  assert_reference_posterior_info(x = rpi)
  po <- posterior(rpi$name, pdb = pdb)
  pdn <- posterior_dimension_names(x = po$dimensions)

  stan_object <- run_stan(po,
                          stan_args = rpi$inference$method_arguments)

  # Compute the diagnostics from the stan object and add it to the slot
  rpi$diagnostics <- compute_stan_sampling_diagnostics(x = stan_object, keep_dimensions = pdn)

  # Create rpd object
  rpd <- reference_posterior_draws(x = stan_object, info = rpi)

  # Subset to relevant parameters (that are used)
  rpd <- subset(rpd, variable = pdn)

  rpd
}




#' @rdname reference_posterior_draws
#' @export
reference_posterior_draws.stanfit <- function(x, info, pdb = pdb_default(), ...){
  checkmate::assert_class(info, "pdb_reference_posterior_info")
  draws <- posterior::as_draws_list(posterior::as_draws(x))
  reference_posterior_draws(draws)
}


#' Extract diagnostics
#'
#' @description
#' The function extracts and computes the relevant diagnostics
#'
#' @param x a [stanfit] object.
#' @param keep_dimensions a regular expression to choose dimensions to keep
#'
#' @keywords internal
#' @noRd
compute_stan_sampling_diagnostics <- function(x, keep_dimensions ){
  checkmate::assert_character(keep_dimensions)

  d <- list()
  pd <- posterior::as_draws(x)
  pds <- posterior::summarise_draws(pd)
  checkmate::assert_subset(keep_dimensions, pds$variable)

  keep_idx <- pds$variable %in% keep_dimensions


  # diagnostic_information
  d$diagnostic_information <- list(names = pds$variable[keep_idx])

  # ndraws
  d$ndraws <- posterior::ndraws(pd)

  # nchains
  d$nchains <- posterior::nchains(pd)

  # ESS bulk
  d$effective_sample_size_bulk <- pds$ess_bulk[keep_idx]

  # ESS tail
  d$effective_sample_size_tail <- pds$ess_tail[keep_idx]

  # r_hat
  d$r_hat <- pds$rhat[keep_idx]

  # divergent_transitions
  hmc_params <- rstan::get_sampler_params(x, inc_warmup = FALSE)
  d$divergent_transitions <- unlist(lapply(hmc_params, function(x) sum(x[, "divergent__"])))

  # expected_fraction_of_missing_information
  d$expected_fraction_of_missing_information <- rstan::get_bfmi(x)

  d
}


#' Construct dimension names from a posterior dimension list
#'
#' @param x a dimensions slot from a [pdb_posterior]
posterior_dimension_names <- function(x){
  checkmate::assert_list(x)
  checkmate::assert_named(x)
  for(i in seq_along(x)) checkmate::assert_int(x[[i]])

  dn <- list()
  for(i in seq_along(x)){
    if(x[[i]] > 1L){
      dn[[i]] <- paste0(names(x)[i], "[", 1:x[[i]], "]")
    } else {
      dn[[i]] <- names(x)[i]
    }
  }
  return(unlist(dn))
}
