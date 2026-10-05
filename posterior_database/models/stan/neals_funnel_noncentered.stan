data {
  int<lower=1> D; 
}
parameters {
  real y; 
  vector[D] x_raw; // The standardized computational variables (this is phi)
}
transformed parameters {
  // We deterministically transform x_raw back into our target x (this is h)
  vector[D] x = x_raw * exp(y / 2.0); 
}
model {
  // y still has the same distribution
  y ~ normal(0, 3);
  
  // The algorithm now samples from a perfectly smooth standard normal!
  x_raw ~ normal(0, 1); 
}
