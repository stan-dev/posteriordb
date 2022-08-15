# remotes::install_github("stan-dev/posteriordb-r")
library(posteriordb)
source("tests/check_posteriordb_content_functions.R")
pdbl <- pdb_local("posterior_database")
status_code <- check_pdb(pdbl, run_stan_code_checks = FALSE)

# Run Stan code for changed or added models
added_modified_paths <- strsplit(readLines(con = "added_modified.txt"), " ")[[1]]
posteriors_to_check <- get_posteriors_from_paths(paths = added_modified_paths, pdbl)

if(length(posteriors_to_check) > 0){
  cat("Checking changed posteriors:\n")
  cat(paste(posteriors_to_check, collapse = "\n"),"\n\n")
  library(rstan)
  for(i in seq_along(posteriors_to_check)){
    post <- pdb_posterior(posteriors_to_check[i], pdbl)
    status_code2 <- posteriordb:::check_pdb_posterior(post, run_stan_code_checks = TRUE)
    posteriordb:::pdb_clear_cache(pdbl)
    status_code <- max(status_code, as.integer(!status_code2))
  }
}

q(status = status_code)
