data {
  int<lower=1> D; // Dimensionality of the lower-level variables
}
parameters {
  real y;         // Top-level parameter controlling the variance
  vector[D] x;    // Lower-level variables
}
model {
  y ~ normal(0, 3);
  
  x ~ normal(0, exp(y / 2.0)); 
}
