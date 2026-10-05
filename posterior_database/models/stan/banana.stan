data {
  int<lower=2> D;        // Target dimension (e.g., 2, 4, 8 from Haario et al., 1999)
  real<lower=0> b;         // Curvature parameter for parabolic transformation
}

transformed data {
  real v = 100.0;        // Variance of first coordinate y[1] (v = 100)
}

parameters {
  real x;           // first coordinate of the banana-shaped distribution
  real y;            // twisted second coordinate of the banana-shaped distribution
  vector[D - 2] y_rest;  // remaining independent coordinates (if D > 2)
}

model {
  // 1. First coordinate
  x ~ normal(0, sqrt(v));
  
  // 2. Second coordinate twisted by parabola
  y ~ normal(-b * (square(x) - v), 1.0);
  
  // 3. Remaining independent dimensions
  if (D > 2) {
    y_rest ~ normal(0, 1.0);
  }
}
