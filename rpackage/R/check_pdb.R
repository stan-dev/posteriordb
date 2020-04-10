#' Check a posterior database
#' @noRd
#' @param pdb a \code{pdb} object
#' @param posterior_idx an index vector indicating what posteriors to check.
#' @return a boolean indicating if the pdb works as it should.
check_pdb <- function(pdb, posterior_idx = NULL) {
  checkmate::assert_class(pdb, "pdb")
  message("Checking posterior database...")
  pns <- posterior_names(pdb)
  if(!is.null(posterior_idx)) pns <- pns[posterior_idx]
  pl <- list()
  for (i in seq_along(pns)) {
    pl[[i]] <- posterior(pns[i], pdb = pdb)
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
    reference_posterior_draws(x = pl[[i]])
    #reference_posterior_expectations(x = pl[[i]])
  }
  message("4. All reference_posteriors_draws can be read.")

  if(is.null(posterior_idx)){
    mnp <- dnp <- rpnp <- character(length(pns))
    for (i in seq_along(pns)) {
      pl[[i]] <- posterior(pns[i], pdb = pdb)
      mnp[i] <- model_info(pl[[i]])$name
      dnp[i] <- data_info(pl[[i]])$name
      tc <- try(rp <- reference_posterior_draws_info(pl[[i]]), silent = TRUE)
      if(!inherits(tc, "try-error")){
        rpnp[i] <- rp$name
      }
    }
    mns <- model_names(pdb)
    dns <- data_names(pdb)
    rpns <- reference_posterior_names(pdb, "draws")
    model_bool <- mns %in% mnp
    if(!all(model_bool)){
      stop("Model(s) " , paste0(mns[!model_bool], collapse = ", "), " is missing in posteriors.", call. = FALSE)
    }
    data_bool <- dns %in% dnp
    if(!all(data_bool)){
      stop("Data " , paste0(dns[!data_bool], collapse = ", "), " is missing in posteriors.", call. = FALSE)
    }
    rp_bool <- rpns %in% rpnp
    if(!all(rp_bool)){
      stop("Reference posteriors " , paste0(rpns[!rp_bool], collapse = ", "), " is missing in posteriors.", call. = FALSE)
    }
    message("5. All data, models and reference posteriors are part of a posteriors.")
  }

  message("Posterior database is ok.\n")
  invisible(TRUE)
}

#' @rdname check_pdb
check_extensive_pdb <- function(pdb, posterior_idx = NULL) {
  checkmate::assert_class(pdb, "pdb")
  check_pdb(pdb, posterior_idx)

  # Extensive checks
  message("Extensive checks...")
  pns <- posterior_names(pdb)
  if(!is.null(posterior_idx)) pns <- pns[posterior_idx]
  pl <- list()
  for (i in seq_along(pns)) {
    pl[[i]] <- posterior(pns[i], pdb = pdb)
  }

  for(i in seq_along(pl)){
    run_stan(pl[[i]])
  }
  message("All posteriors with stan code can be run.")


}
