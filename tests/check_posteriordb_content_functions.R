#' Returns posteriors from paths
#'
#' @details
#' The function takes paths to files in the posterior
#' database and return the posteriors that uses these parts.
#'
#' The point is to extract what posteriors that need to be
#' checked more thorough in the CI.
#'
#' @param paths to extract posteriors for
#' @param pdb a `posteriordb` connection
get_posteriors_from_paths <- function(paths, pdb){
  pns <- posteriordb::posterior_names(pdbl)
  mns <- posteriordb::model_names(pdbl)
  dns <- posteriordb::data_names(pdbl)

  full_pns <- character(0)
  for(i in seq_along(paths)){
    if(grepl("posterior_database/data/", x = paths[i])){
      dn <- strsplit(basename(paths[i]), split = "\\.")[[1]][1]
      pdbd <- try(pdb_data(dn, pdb))
      if(!inherits(pdbd, "try-error")) full_pns <- c(full_pns, posterior_names(x = pdbd))
    }
    if(grepl("posterior_database/models/", x = paths[i])){
      mn <- strsplit(basename(paths[i]), split = "\\.")[[1]][1]
      pdbm <- try(pdb_stan_code(mn, pdb))
      if(!inherits(pdbm, "try-error")) full_pns <- c(full_pns, posterior_names(x = pdbm))
    }
    if(grepl("posterior_database/posteriors/", x = paths[i])){
      po <- strsplit(basename(paths[i]), split = "\\.")[[1]][1]
      pdbpo <- try(pdb_posterior(po, pdb))
      if(!inherits(pdbpo, "try-error")) full_pns <- c(full_pns, posterior_names(pdbpo))
    }
    if(grepl("posterior_database/reference_posteriors/", x = paths[i])){
      rpd <- strsplit(basename(paths[i]), split = "\\.")[[1]][1]
      pdbpo <- try(pdb_posterior(rpd, pdb))
      if(!inherits(pdbpo, "try-error")) full_pns <- c(full_pns, posterior_names(pdbpo))
    }
  }
  return(unique(full_pns))
}

if(FALSE){
  # Test cases
  pdbl <- pdb_local()
  paths <- c("posterior_database/data/info/arma.info.json",
             "posterior_database/models/stan/accel_splines.stan",
             "posterior_database/posteriors/GLM_Poisson_Data-GLM_Poisson_model.json",
             "posterior_database/posteriors/arma-arma11.json",
             "posterior_database/data/data/radon_mn.json.zip",
             "posterior_database/reference_posteriors/summary_statistics/mean/info/earnings-logearn_logheight_male.info.json")
  res <- get_posteriors_from_paths(paths, pdb = pdbl)

  paths <- c(".github/workflows/posteriordb_content.yml", "tests/check_posteriordb_content.R", "posterior_database/models/stan/accel_splines.stan")
  res <- get_posteriors_from_paths(paths, pdb = pdbl)

}
