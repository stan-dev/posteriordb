data {
    int<lower=2> n1; // number of dimensions for the first block
    int<lower=1> n2; // number of dimensions for the second block
    real<lower=0> a; // scale for the first variable's marginal variance
    real<lower=0> b; // scale for the conditional variance
    real mu;         // mean for the first variable
}
parameters {
    real x1;         // root variable shared across blocks
    matrix[n2, n1 - 1] x_rest;  // remaining variables for the second block
}
model {
    target += -a * square(x1 - mu);

    for (j in 1:n2) {
        real prev = x1;   // chain in each block starts conditioned on shared x1

        for (i in 1:(n1 - 1)) {
            target += -b * square(x_rest[j, i] - square(prev));
            prev = x_rest[j, i];  // update previous variable for the next iteration
        }
    }
}
