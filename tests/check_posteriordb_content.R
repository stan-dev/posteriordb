# remotes::install_github("stan-dev/posteriordb-r")
library(posteriordb)
source("tests/check_posteriordb_content_functions.R")
pdbl <- pdb_local("posterior_database")
status_code <- check_pdb(pdbl, run_stan_code_checks = FALSE)

# Run Stan code for changed or added models
added_modified_paths <- strsplit(readLines(con = "added_modified.txt"), " ")[[1]]
posteriors_to_check <- get_posteriors_from_paths(paths = added_modified_paths, pdbl)
if(length(posteriors_to_check) > 0){
  status_code2 <- check_pdb(pdbl, posterior_names_to_check = posteriors_to_check, run_stan_code_checks = TRUE)
  status_code <- max(status_code, status_code2)
}

q(status = status_code)
