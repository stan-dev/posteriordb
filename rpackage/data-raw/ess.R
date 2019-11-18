S <- 100000
essb <- numeric(S)
esst <- numeric(S)
for(i in 1:S){
  print(i)
  x <- matrix(rnorm(10000), ncol = 10)
  essb[i] <- posterior::ess_bulk(x)
  esst[i] <- posterior::ess_tail(x)
}
usethis::use_data(essb)
usethis::use_data(esst)
