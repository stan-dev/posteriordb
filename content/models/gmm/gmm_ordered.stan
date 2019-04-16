data {
 int D; //number of dimensions
 int K; //number of gaussians
 int N; //number of data
 matrix [N, D] X; // data
}

parameters {
 simplex[K] pi; // mixing proportions
 ordered[D] mu[K]; // mixture component means
 cholesky_factor_corr[D] L[K]; // cholesky factor of covariance
}

model {
 real ps[K];
 
 // prior
 for(k in 1:K){
   mu[k] ~ normal(0, 10);
   L[k] ~ lkj_corr_cholesky(1);
 }
 // likelihood
 for (n in 1:N){
   for (k in 1:K){
     ps[k] = log(pi[k]) + multi_normal_cholesky_lpdf(X[n,] | mu[k], L[k]);
     target += log_sum_exp(ps); 
   }
 }
}
