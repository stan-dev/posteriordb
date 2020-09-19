#' Check the content a posterior database
#'
#' @param pdb a \code{pdb} object
#' @param posterior_idx an index vector indicating what posteriors to check.
#' @param posterior_list a list of \code{pdb_posterior} objects.
#' @param po a \code{pdb_posterior} object.
#'
#' @details
#' [check_pdb()] checks that the content exists as specified
#' [check_pdb_run_stan()] test to run all posteriors with stan models.
#' [check_pdb_stan_syntax()] check that all stan model code files can be parsed.
#' [check_pdb_read_posteriors()] check that posteriors can be read.
#' [check_pdb_aliases()] check that all alias are correct.
#' [check_pdb_read_model_code()] check that posteriors can be read.
#' [check_pdb_posteriors()] check a vector of posterior names.
#' [check_pdb_references()] check that all references in posteriors also exist in bibtex.
#' [check_pdb_all_models_have_posterior()] check that all models belong to a posterior
#' [check_pdb_all_data_have_posterior()] check that all datasets belong to a posterior
#' [check_pdb_all_reference_posteriors_have_posterior()] check that all reference posteriors belong to a posterior
#'
#' @return a boolean indicating if the pdb works as it should.
#'
check_pdb <- function(pdb, posterior_idx = NULL) {
  checkmate::assert_class(pdb, "pdb")
  checkmate::assert_integerish(posterior_idx, null.ok = TRUE)

  message("Checking posterior database...")

  pl <- check_pdb_read_posteriors(pdb, posterior_idx)
  message("- All posteriors can be read.")

  check_pdb_read_model_code(pl)
  message("- All model_code can be read.")

  check_pdb_read_data(pl)
  message("- All data can be read.")

  check_pdb_read_reference_posterior_draws(pl)
  message("- All reference_posteriors_draws can be read.")

  check_pdb_aliases(pdb)
  message("- Aliases are ok.")

  if(is.null(posterior_idx)){
    suppressMessages(check_pdb_references(pdb))
    message("- References and bibliography are ok.")

    check_pdb_all_models_have_posterior(pdb)
    check_pdb_all_data_have_posterior(pdb)
    check_pdb_all_reference_posteriors_have_posterior(pdb)
    message("- All data, models and reference posteriors are part of a posterior.")
  }

  message("\nPosterior database is ok.\n")
  invisible(TRUE)
}

#' @rdname check_pdb
check_pdb_read_posteriors <- function(pdb, posterior_idx = NULL){
  checkmate::assert_class(pdb, "pdb")
  checkmate::assert_integerish(posterior_idx, null.ok = TRUE)

  pns <- posterior_names(pdb)
  if(!is.null(posterior_idx)) pns <- pns[posterior_idx]
  pl <- list()
  for (i in seq_along(pns)) {
    pl[[i]] <- posterior(pns[i], pdb = pdb)
  }
  return(invisible(pl))
}

#' @rdname check_pdb
check_pdb_read_model_code <- function(posterior_list){
  pl <- lapply(posterior_list, checkmate::assert_class, classes = "pdb_posterior")
  for (i in seq_along(pl)) {
    model_info(pl[[i]])
    stan_code(pl[[i]])
  }
}

#' @rdname check_pdb
check_pdb_aliases <- function(pdb){
  a <- pdb_aliases("posteriors", pdb)
  checkmate::assert_character(names(a), unique = TRUE)
  pn <- unname(unlist(a))
  pdb_posterior_names <- posterior_names(pdb)
  checkmate::assert_subset(pn, pdb_posterior_names)
  checkmate::assert_true(all(!names(a) %in% pdb_posterior_names))
}

#' @rdname check_pdb
check_pdb_read_data <- function(posterior_list){
  pl <- lapply(posterior_list, checkmate::assert_class, classes = "pdb_posterior")
  for (i in seq_along(pl)) {
    data_info(x = pl[[i]])
    sd <- stan_data(x = pl[[i]])
    pdb_cache_rm(sd, pl$pdb[[i]])
  }
}

#' @rdname check_pdb
check_pdb_read_reference_posterior_draws <- function(posterior_list){
  pl <- lapply(posterior_list, checkmate::assert_class, classes = "pdb_posterior")
  for (i in seq_along(pl)) {
    if(is.null(pl[[i]]$reference_posterior_name)) next
    rp <- reference_posterior_draws(x = pl[[i]])
    pdb_cache_rm(rp, pl$pdb[[i]])
  }
}

#' @rdname check_pdb
check_pdb_run_stan <- function(pdb, posterior_idx = NULL) {
  checkmate::assert_class(pdb, "pdb")

  message("Check that stan can be run for all models ...")
  pns <- posterior_names(pdb)
  if(!is.null(posterior_idx)) pns <- pns[posterior_idx]
  pl <- list()
  for (i in seq_along(pns)) {
    pl[[i]] <- posterior(pns[i], pdb = pdb)
  }

  try_list <- list()
  for(i in seq_along(pl)){
    try_list[[i]] <- try(suppressWarnings(so <- utils::capture.output(run_stan(pl[[i]], stan_args = list(iter = 2, warmup = 1, chains = 1)))))
    if(inherits(try_list[[i]], "try-error")){
      message("'", pl[[i]]$name, "' cannot be run with stan.")
    } else {
      message("'", pl[[i]]$name, "' is working with stan.")
    }
  }
  message("All posteriors with stan code can be run.")

}

#' @rdname check_pdb
check_pdb_posterior_run_stan <- function(po) {
  checkmate::assert_class(po, "pdb_posterior")
  suppressWarnings(so <- utils::capture.output(run_stan(po, stan_args = list(iter = 2, warmup = 1, chains = 1))))
  so
}


#' @rdname check_pdb
check_pdb_stan_syntax <- function(pdb, posterior_idx = NULL) {
  checkmate::assert_class(pdb, "pdb")

  message("Checking stan syntax...")
  pns <- posterior_names(pdb)
  if(!is.null(posterior_idx)) pns <- pns[posterior_idx]
  pl <- list()
  for (i in seq_along(pns)) {
    pl[[i]] <- posterior(pns[i], pdb = pdb)
  }

  for(i in seq_along(pl)){
    check_posterior_stan_syntax(pl[[i]])
  }
  message("All posteriors with stan code has correct stan syntax.")
}

check_posterior_stan_syntax <- function(po) {
  checkmate::assert_class(po, "pdb_posterior")
  suppressWarnings(sp <- rstan::stanc(model_code = stan_code(po), model_name = po$model_name))
  sp
}


#' @rdname check_pdb
check_pdb_references <- function(pdb, posterior_idx = NULL) {
  checkmate::assert_class(pdb, "pdb")

  message("Checking references...")
  pns <- posterior_names(pdb)
  if(!is.null(posterior_idx)) pns <- pns[posterior_idx]
  refs <- list()
  for (i in seq_along(pns)) {
    po <- posterior(pns[i], pdb = pdb)
    refs[[length(refs) + 1]] <- po$references
    refs[[length(refs) + 1]] <- model_info(po)$references
    refs[[length(refs) + 1]] <- data_info(po)$references
  }
  refs <- unique(unlist(refs))
  refs <- refs[nchar(refs) > 0]

  bib <- bibliography(pdb)
  bibnms <- names(bib)

  ref_in_bib <- refs %in% bibnms
  if(any(!ref_in_bib)){
    stop("Reference '", refs[!ref_in_bib], "' exist in database but not in the bibliography.", call. = FALSE)
  }

  bib_in_ref <- bibnms %in% refs
  if(any(!bib_in_ref)){
    stop("Reference '", bibnms[!bib_in_ref], "' in bibliography but not in any posterior, data or model.", call. = FALSE)
  }

  message("All references are correct...")
}

#' @rdname check_pdb
check_pdb_all_models_have_posterior <- function(pdb){
  checkmate::assert_class(pdb, "pdb")
  pn <- posterior_names(pdb)
  mnp <- character(length(pn))
  pl <- list()
  for (i in seq_along(pn)) {
    pl[[i]] <- posterior(pn[i], pdb = pdb)
    mnp[i] <- model_info(pl[[i]])$name
  }

  mns <- model_names(pdb)

  model_bool <- mns %in% mnp
  if(!all(model_bool)){
    stop("Model(s) " , paste0(mns[!model_bool], collapse = ", "), " is missing in posteriors.", call. = FALSE)
  }
}

#' @rdname check_pdb
check_pdb_all_data_have_posterior <- function(pdb){
  checkmate::assert_class(pdb, "pdb")
  pn <- posterior_names(pdb)
  dnp <- character(length(pn))
  pl <- list()
  for (i in seq_along(pn)) {
    pl[[i]] <- posterior(pn[i], pdb = pdb)
    dnp[i] <- data_info(pl[[i]])$name
  }
  dns <- data_names(pdb)

  data_bool <- dns %in% dnp
  if(!all(data_bool)){
    stop("Data " , paste0(dns[!data_bool], collapse = ", "), " is missing in posteriors.", call. = FALSE)
  }

}

#' @rdname check_pdb
check_pdb_all_reference_posteriors_have_posterior <- function(pdb){
  checkmate::assert_class(pdb, "pdb")
  pn <- posterior_names(pdb)
  rpnp <- character(length(pn))
  pl <- list()
  for (i in seq_along(pn)) {
    pl[[i]] <- posterior(pn[i], pdb = pdb)
    tc <- try(rp <- reference_posterior_draws_info(pl[[i]]), silent = TRUE)
    if(!inherits(tc, "try-error")){
      rpnp[i] <- rp$name
    }
  }

  rpns <- reference_posterior_names(pdb, "draws")

  rp_bool <- rpns %in% rpnp
  if(!all(rp_bool)){
    stop("Reference posteriors " , paste0(rpns[!rp_bool], collapse = ", "), " is missing in posteriors.", call. = FALSE)
  }
}
