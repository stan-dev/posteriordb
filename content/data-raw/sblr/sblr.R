#' Generate simulated data using a linear regression model
#' 
#' @details Simulate a standard linear regression model 
#' 
#' @param n Number of observations
#' @param beta True values of \code{beta}.
#' @param beta_cov True posterior covariance of parameters
#' @param sample_size_independent_cov Should the posterior covariance be the same for any N? Default is \code{FALSE}.
#' @param sigma The noise standard deviation
#' @param digits The number of digits used in the dataset
#' 
simulate_data_linear_regression <- 
  function(n, 
           beta,
           beta_cov = diag(length(beta)), 
           sigma = 1,
           sample_size_independent_cov = FALSE, 
           digits = 5){
  checkmate::assert_int(n, lower = 1)
  checkmate::assert_numeric(beta, min.len = 1)
  checkmate::assert_matrix(beta_cov, nrows = length(beta), ncols = length(beta))
  checkmate::assert_number(sigma, lower = .Machine$double.eps)
  checkmate::assert_flag(sample_size_independent_cov)
  checkmate::assert_int(digits)
  
  D <- length(beta)
  sig <- solve(beta_cov)
  if(sample_size_independent_cov) sig <- sig/n
  x <- mvtnorm::rmvnorm(n = n, mean = rep(0, D), sigma = sig)
  x <- round(x, digits = digits)
  if(length(beta) == 1) beta <- as.matrix(rep(beta, D))
  checkmate::assert_numeric(beta, len = D)

  y <- as.vector(x%*%beta + rnorm(n, sd = sigma))
  y <- round(y, digits = digits)
  list(X = x, D = as.integer(D), N = as.integer(n), y = y)
}

set.seed(4711)
sblrD5n50I <- simulate_data_linear_regression(n = 50, beta = rep(1, 5), digits = 3)
writeLines(jsonlite::toJSON(sblrD5n50I, pretty = TRUE, auto_unbox = TRUE), con = "sblrD5n50I.json")
zip(zipfile = "sblrD5n50I.json.zip", files = "sblrD5n50I.json")

set.seed(4712)
sblrD5n500I <- simulate_data_linear_regression(n = 500, beta = rep(1, 5), digits = 3)
writeLines(jsonlite::toJSON(sblrD5n500I, pretty = TRUE, auto_unbox = TRUE), con = "sblrD5n500I.json")
zip(zipfile = "sblrD5n500I.json.zip", files = "sblrD5n500I.json")

set.seed(4713)
sblrD5n50C07 <- simulate_data_linear_regression(n = 50, beta = rep(1, 5), beta_cov = 0.3 * diag(5) + 0.7, digits = 3)
writeLines(jsonlite::toJSON(sblrD5n50C07, pretty = TRUE, auto_unbox = TRUE), con = "sblrD5n50C07.json")
zip(zipfile = "sblrD5n50C07.json.zip", files = "sblrD5n50C07.json")

set.seed(4714)
sblrD5n500C07 <- simulate_data_linear_regression(n = 500, beta = rep(1, 5), beta_cov = 0.3 * diag(5) + 0.7, digits = 3)
writeLines(jsonlite::toJSON(sblrD5n500C07, pretty = TRUE, auto_unbox = TRUE), con = "sblrD5n500C07.json")
zip(zipfile = "sblrD5n500C07.json.zip", files = "sblrD5n500C07.json")




