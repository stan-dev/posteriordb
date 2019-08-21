data {
 int D; //number of dimensions
 int K; //number of gaussians
 int N; //number of data
 matrix [N, D] X; // data
}

parameters {
  simplex[K] pi; // mixing proportions
  vector[D] mu[K]; // mixture component means
  vector<lower=0>[D] sigma[K]; // marginal sd per component
}

model {
 real ps[K];

 // prior
 for(k in 1:K){
   mu[k] ~ normal(0, 10);
   sigma[k] ~ normal(0, 1);
 }
 // likelihood
 for (n in 1:N){
   for (k in 1:K){
     ps[k] = log(pi[k]) + normal_lpdf(X[n,] | mu[k], sigma[k]);
   }
   target += log_sum_exp(ps);
 }
}
