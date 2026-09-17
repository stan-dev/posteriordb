data {
  int<lower=1> D; // Dimensionality of the lower-level variables
}
parameters {
  real y;         // Top-level parameter controlling the variance
  vector[D] x;    // Lower-level variables
}
model {
  // The top-level parameter has a fixed, broad marginal distribution
  y ~ normal(0, 3);
  
  // The lower-level variables' scale depends directly on y
  x ~ normal(0, exp(y / 2.0)); 
}
