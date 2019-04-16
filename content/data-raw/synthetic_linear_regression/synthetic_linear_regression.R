#' Generate simulated data using a linear regression model
#' 
#' @details Simulate a standard linear regression model 
#' 
#' @param D dimension size/number of coefficients
#' @param N Number of observations
#' @param beta True values of \code{beta}.
#' @param beta_cov True posterior covariance of parameters
#' @param sample_size_independent_cov Should the posterior covariance be the same for any N? Default is \code{FALSE}.
#' @param sigma The noise variance
#' @param seed The numeric seed to use for simulation
#' 
generate_synthetic_linear_regression_data <- 
  function(D, 
           N, 
           beta = 1,
           beta_cov = diag(D), 
           sample_size_independent_cov = FALSE,
           seed = 4711, 
           sigma = 1, 
           round.digits = 5){
  checkmate::assert_int(D)
  checkmate::assert_int(N)
  checkmate::assert_numeric(beta, min.len = 1, max.len = D)
  set.seed(seed)
  sig <- solve(beta_cov)
  if(sample_size_independent_cov) sig <- sig/N
  x <- mvtnorm::rmvnorm(n = N, mean = rep(0, D), sigma = sig)
  x <- round(x, digits = round.digits)
  if(length(beta) == 1) beta <- as.matrix(rep(beta, D))
  checkmate::assert_numeric(beta, len = D)

  y <- as.vector(x%*%beta + rnorm(N, sd = sigma))
  y <- round(y, digits = round.digits)
  list(X = x, D = as.integer(D), N = as.integer(N), y = y)
}




