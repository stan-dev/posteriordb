data {
    int<lower=2> D; // dimensions
    real<lower=0> v; // variance of the first dimension
    real<lower=0> b; //curvature parameter
}
parameters {
   vector[D] y; //
}
model {
    target += -0.5 * (y[1]^2)/(v) - 0.5 * (y[2] + b * (y[1]^2 - v))^2 - 0.5 * dot_self(y[3:D]);
}
