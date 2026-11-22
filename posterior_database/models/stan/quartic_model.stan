data {
  real y;   
  real<lower=0> sigma;
}
parameters {
  vector[2] theta;   // theta[1] = \theta_0 (quartic term), theta[2] = \theta_1 
}
model {
  real F = square(theta[2]) + square(theta[1]) * (square(theta[1]) - 0.5);
  target += std_normal_lpdf(theta);
  target += normal_lpdf(y | F, sigma);
}
