#' Generate simulated data using a gaussian mixture model
#' 
#' @details Simulate a standard linear regression model 
#' 
#' @param pi vector of components (K)
#' @param N Number of observations
#' @param mu list with K elements with vector of length data (D)imensions
#' @param Cov list with K elements with covariance matrix rank D
#' @param seed The numeric seed to use for simulation
#' @param round.digits The number of digits for data
#' 
simulate_data_gaussian_mixture <- 
  function(n, 
           pi, 
           mu,
           Sigma,
           digits = 5){
  checkmate::assert_int(n, lower = 1)
  checkmate::assert_numeric(pi, lower = 0, upper = 1)
  checkmate::assert_true(sum(pi) == 1)
  checkmate::assert_list(mu, len = length(pi))
  for(i in seq_along(mu)){
    checkmate::assert_numeric(mu[[i]], len = length(mu[[1]]))
  }
  checkmate::assert_list(Sigma, len = length(pi))
  for(i in seq_along(Sigma)){
    checkmate::assert_matrix(Sigma[[i]], nrows = length(mu[[1]]), ncols = length(mu[[1]]))
  }
  checkmate::assert_int(digits)
  
  component <- sample(1:length(pi), size = n, replace = TRUE, prob = pi)

  X <- matrix(0, nrow = n, ncol = length(mu[[1]]))
  for(i in 1:n){
    X[i, ] <- mvtnorm::rmvnorm(1, mu[[component[i]]], sigma = Sigma[[component[i]]], method = "eigen")
  }  
  X <- round(X, digits = digits)
  list(N = as.integer(n), D = as.integer(length(mu[[1]])), K = as.integer(length(pi)), X = X, component = as.integer(component))

}


set.seed(4711)
syn_gmK3D2n300 <- simulate_data_gaussian_mixture(n = 300,
                                            pi = c(0.5,0.3,0.2),
                                            mu = list(c(0,0), c(3,3), c(6,6)),
                                            Sigma = list(diag(2), 1.8 * diag(2) - 0.8, 0.2 * diag(2) + 0.8),
                                            digits = 3)
writeLines(jsonlite::toJSON(syn_gmK3D2n300, pretty = TRUE, auto_unbox = TRUE), con = "syn_gmK3D2n300.json")
zip(zipfile = "syn_gmK3D2n300.json.zip", files = "syn_gmK3D2n300.json")

set.seed(4712)
syn_gmK2D1n200 <- simulate_data_gaussian_mixture(n = 200,
                                            pi = c(0.7,0.3),
                                            mu = list(2,-2),
                                            Sigma = list(matrix(1), matrix(2)),
                                            digits = 3)
writeLines(jsonlite::toJSON(syn_gmK2D1n200, pretty = TRUE, auto_unbox = TRUE), con = "syn_gmK2D1n200.json")
zip(zipfile = "syn_gmK2D1n200.json.zip", files = "syn_gmK2D1n200.json")



