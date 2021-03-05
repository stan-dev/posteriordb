
supported_summary_statistic_types <- function() c("mean", "sd")

summary_statistic_class_name <- function(type){
  checkmate::assert_subset(type, supported_summary_statistic_types())
  paste0("pdb_summary_statistic_", type)
}

supported_summary_statistic_classes <- function() {
  summary_statistic_class_name(supported_summary_statistic_types())
}


#' Extract the type of summary statistic
#'
#' @param x a [pdb_reference_posterior_summary_statistic]
#'
summary_statistic_type <- function(x){
  checkmate::assert_class(x, "pdb_reference_posterior_summary_statistic")
  sst <- supported_summary_statistic_types()
  bool <- logical(length(sst))
  for(i in seq_along(sst)){
    bool[i] <- grepl(x = class(x)[1], pattern = sst[i])
  }
  checkmate::assert_true(sum(bool) == 1L)
  sst[bool]
}


#' @export
print.pdb_reference_posterior_summary_statistic <- function(x, ...) {
  cat(paste0("Posterior: ",  info(x)$name, "\n\n"))
  attr(x, "info") <- NULL
  attr(x, "pdb") <- NULL
  x <- unclass(x)
  print(x)
}


assert_reference_posterior_summary_statistic <- function(x){
  checkmate::assert_class(x, c("pdb_reference_posterior_summary_statistic"))
  sst <- summary_statistic_type(x)

  checkmate::assert_names(names(x)[1], identical.to = c("names"))
  checkmate::assert_true(all(grepl(names(x)[-1], pattern = sst)))
  checkmate::assert_true(any(grepl(names(x)[-1], pattern = paste0("mcse_", sst))))

  checkmate::assert_character(x[[1]])
  for(j in 2:length(x)){
    checkmate::assert_numeric(x[[j]])
  }
}
