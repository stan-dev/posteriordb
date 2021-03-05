#' Assert that all checks of the reference posterior draws
#' are true
#'
#' @details
#' This functionasserts that the reference posterior draws comply
#' with the criterias of the reference posterior draws.
#'
#' See \url{https://github.com/stan-dev/posteriordb/blob/master/doc/REFERENCE_POSTERIOR_DEFINITION.md} for details.
#'
#' @param x a [pdb_reference_posterior_draws] object
#'
#' @export
assert_checked_reference_posterior_draws <- function(x){
  UseMethod("assert_checked_reference_posterior_draws")
}

#' @rdname assert_checked_reference_posterior_draws
#' @export
assert_checked_reference_posterior_draws.pdb_reference_posterior_draws <- function(x){
  rpi <- info(x)
  assert_checked_reference_posterior_draws(rpi)
}

#' @rdname assert_checked_reference_posterior_draws
#' @export
assert_checked_reference_posterior_draws.pdb_reference_posterior_info <- function(x){
  checkmate::assert_true(x$checks_made$ndraws_is_10k)
  checkmate::assert_true(x$checks_made$nchains_is_gte_4)
  checkmate::assert_true(x$checks_made$ess_within_bounds)
  checkmate::assert_true(x$checks_made$r_hat_below_1_01)
  checkmate::assert_true(x$checks_made$efmi_above_0_2)
}


#' @rdname assert_checked_reference_posterior_draws
#' @export
assert_checked_summary_statistics_draws <- function(x){
  UseMethod("assert_checked_summary_statistics_draws")
}

#' @rdname assert_checked_reference_posterior_draws
#' @export
assert_checked_summary_statistics_draws.pdb_reference_posterior_draws <- function(x){
  rpi <- info(x)
  assert_checked_summary_statistics_draws(rpi)
}

#' @rdname assert_checked_reference_posterior_draws
#' @export
assert_checked_summary_statistics_draws.pdb_reference_posterior_summary_statistic <- function(x){
  rpi <- info(x)
  assert_checked_summary_statistics_draws(rpi)
}

#' @rdname assert_checked_reference_posterior_draws
#' @export
assert_checked_summary_statistics_draws.pdb_reference_posterior_info <- function(x){
  checkmate::assert_true(x$checks_made$ndraws_is_gte_10k)
  checkmate::assert_true(x$checks_made$nchains_is_gte_4)
  checkmate::assert_true(x$checks_made$ess_within_bounds)
  checkmate::assert_true(x$checks_made$r_hat_below_1_01)
  checkmate::assert_true(x$checks_made$efmi_above_0_2)
}
