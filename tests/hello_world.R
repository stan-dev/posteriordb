# remotes::install_github("stan-dev/posteriordb-r")
library(posteriordb)
pdbl <- pdb_local("posterior_database")
check_pdb(pdbl, run_stan_code_checks = FALSE)

print("hello world!")
message("hello world!")
