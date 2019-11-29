#' Generate simulated data using a linear regression model
#'
#' @details
#' Simulate data for a Bayesian standard linear regression model
#' with noninformative priors.
#'
#' @param n Number of observations
#' @param beta_mean True mean values of \code{beta}.
#' @param beta_cov True posterior covariance of \code{beta}.
#' @param sigma The noise standard deviation. Defaults to 1.
#'
simulate_data_linear_regression <-
  function(n,
           beta_mean,
           beta_sigma = diag(length(beta_mean)),
           sigma = 1){
  checkmate::assert_int(n, lower = 1)
  checkmate::assert_numeric(beta_mean, min.len = 1)
  checkmate::assert_matrix(beta_sigma, nrows = length(beta_mean), ncols = length(beta_mean))
  checkmate::assert_number(sigma, lower = .Machine$double.eps)

  beta_mean <- as.matrix(beta_mean)
  D <- length(beta_mean)
  sig <- solve(beta_sigma)
  x <- mvtnorm::rmvnorm(n = n, mean = rep(0, D), sigma = sigma^2 * sig * n)
  y <- as.vector(x%*%beta_mean + rnorm(n, sd = sigma))
  list(y = y, X = x, D = as.integer(D), N = as.integer(n))
}

# Set parameters
beta_mean <- rep(1, 5)
beta_sigma_i <- diag(rep(0.01, length(beta_mean)))
beta_sigma_c <- (diag(0.2, length(beta_mean)) + 0.8) / 100

set.seed(4711)
sblri <- simulate_data_linear_regression(n = 100, beta_mean = beta_mean, beta_sigma = beta_sigma_i)
set.seed(4712)
sblrc <- simulate_data_linear_regression(n = 100, beta_mean = beta_mean, beta_sigma = beta_sigma_c)
