#' Simulated values for effective sample size (tail and bulk)
#'
#' @description
#' A simulated NULL distribution for ESS tail (esst) and ESS bulk (essb).
#'
#' The variance in ESS can be quite large so to test that a gold standard
#' posterior contains roughly indpendent draws, we simulate perfectly
#' independent draws and compute the ESS distribution.
#'
#' This is mainly used to test gold standard posteriors-
#'
#' See `data-raw/ess.R` for simulation code.
#'
#' @usage `data("essb")`
#'
"essb"

#' @usage `data("esst")`
#'
#' @rdname essb
"esst"
