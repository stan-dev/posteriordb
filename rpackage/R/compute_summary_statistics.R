#' Compute Summary statistics from a reference posterior
#'
#' @param rpd a [reference_posterior_summary_statistic] object
#' @param summary_statistic summary statistic to compute
#'
#' @export
compute_reference_posterior_summary_statistic <- function(rpd, summary_statistic = "mean"){
  checkmate::assert_class(rpd, classes = "pdb_reference_posterior_draws")
  rpi <- info(rpd)
  checkmate::assert_class(rpi, classes = "pdb_reference_posterior_info")
  checkmate::assert_choice(summary_statistic, supported_summary_statistic_types())
  assert_checked_summary_statistics_draws(rpd)

  if(summary_statistic == "mean"){
    res <- posterior::summarise_draws(rpd, "mean", "mcse_mean")
    res <- as.list(res)
    names(res)[1] <- "names"
    rpi$versions$r_summary_statistic <- paste0("posterior R package, version ", utils::packageVersion("posterior"))
  } else if (summary_statistic == "sd"){
    res <- posterior::summarise_draws(rpd, "sd", "mcse_sd")
    res <- as.list(res)
    names(res)[1] <- "names"
    rpi$versions$r_summary_statistic <- paste0("posterior R package, version ", utils::packageVersion("posterior"))
  } else {
    stop("Summary statistic is not implemented.")
  }

  rpss <- reference_posterior_summary_statistic(res, rpi, summary_statistic)
  rpss
}

#' @rdname compute_reference_posterior_summary_statistic
#' @export
compute_summary_statistic <- compute_reference_posterior_summary_statistic
