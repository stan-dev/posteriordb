
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






#' Extract data for posterior
#'
#' @inheritParams model_code_file_path
#' @export
reference_posterior_draws_file_path <- function(x, ...) {
  UseMethod("reference_posterior_draws_file_path")
}

#' @rdname reference_posterior_draws_file_path
#' @export
reference_posterior_draws_file_path.pdb_posterior <- function(x, ...) {
  if(is.null(x$reference_posterior_name)) stop2("There is currently no gold standard for this posterior.")
  reference_posterior_draws_file_path(x$reference_posterior_name, pdb = pdb(x))
}

#' @rdname reference_posterior_draws_file_path
#' @export
reference_posterior_draws_file_path.character <- function(x, pdb = pdb_default(), ...) {
  checkmate::assert_string(x)
  fp <- paste0("reference_posteriors/draws/draws/", x, ".json")
  rpfp <- pdb_cached_local_file_path(pdb, path = fp, unzip = TRUE)
  checkmate::assert_file_exists(rpfp)
  rpfp
}

#' @rdname reference_posterior_draws_file_path
#' @export
reference_posterior_draws_file_path.pdb_reference_posterior_info <- function(x, pdb = pdb_default(), ...) {
  reference_posterior_draws_file_path(x$name, pdb, ...)
}


#' Reference posterior summary statistics
#'
#' @param x a [posterior] object or a posterior name.
#' @param pdb a [pdb] object (if [x] is a posterior name)
#' @param info a [pdb_reference_posterior_info] object
#' @param type the type of summary statistic to extract
#' @param ... further arguments supplied to specific methods.
#' @return a [pdb_reference_posterior_summary_statistic] object.
#' @export
reference_posterior_summary_statistic <- function(x, ...){
  UseMethod("reference_posterior_summary_statistic")
}

#' @rdname reference_posterior_summary_statistic
#' @export
pdb_reference_posterior_summary_statistic <- reference_posterior_summary_statistic

#' @rdname reference_posterior_summary_statistic
#' @export
reference_posterior_summary_statistic.character <- function(x, pdb = pdb_default(), type, ...){
  reference_posterior_summary_statistic(posterior(x, pdb = pdb), type)
}

#' @rdname reference_posterior_summary_statistic
#' @export
reference_posterior_summary_statistic.pdb_posterior <- function(x, type, ...){
  read_reference_posterior_summary_statistic(x = x$reference_posterior_name, pdb = pdb(x), type = type)
}

#' @rdname reference_posterior_summary_statistic
#' @export
reference_posterior_summary_statistic.pdb_reference_posterior_info <- function(x, pdb = pdb_default(), type, ...){
  read_reference_posterior_summary_statistic(x = x$name, pdb = pdb, type = type)
}

#' @rdname reference_posterior_summary_statistic
#' @export
reference_posterior_summary_statistic.list <- function(x, info, type, ...){
  checkmate::assert_class(info, "pdb_reference_posterior_info")
  checkmate::assert_choice(type, supported_summary_statistic_types())
  attr(x, "info") <- info
  class(x) <- c(summary_statistic_class_name(type), "pdb_reference_posterior_summary_statistic", "list")
  assert_reference_posterior_summary_statistic(x)
  x
}


#' Read reference_posterior_draws json object
#' @param x a data, model or posterior name
#' @param pdb a posterior db object to access the info json from
#' @param ... further arguments. Currently not used.
#' @noRd
#' @keywords internal
read_reference_posterior_summary_statistic <- function(x, pdb, type, ...) {
  checkmate::assert_string(x, null.ok = TRUE)
  checkmate::assert_choice(type, supported_summary_statistic_types())

  if(is.null(x)) stop("There is currently no reference posterior for this posterior.", call. = FALSE)
  checkmate::assert_class(pdb, classes = "pdb")

  rpssfp <- pdb_cached_local_file_path(pdb, file.path("reference_posteriors", "summary_statistics", type, type,  paste0(x, ".json")), unzip = FALSE)
  rpssd <- jsonlite::read_json(rpssfp, simplifyVector = TRUE)

  rpssi <- reference_posterior_info(x, pdb, type = type)
  rpss <- reference_posterior_summary_statistic(rpssd, rpssi, type)

  assert_reference_posterior_summary_statistic(rpss)
  rpss
}


#' @rdname reference_posterior_summary_statistic
#' @export
reference_posterior_summary_statistics <- function(x, ...){
  UseMethod("reference_posterior_summary_statistics")
}

#' @rdname reference_posterior_summary_statistic
#' @export
pdb_reference_posterior_summary_statistics <- reference_posterior_summary_statistics

#' @rdname reference_posterior_summary_statistic
#' @export
reference_posterior_summary_statistics.character <- function(x, pdb = pdb_default(), ...){
  reference_posterior_summary_statistics(x = posterior(x, pdb = pdb))
}

#' @rdname reference_posterior_summary_statistic
#' @export
reference_posterior_summary_statistics.pdb_posterior <- function(x, ...){
  ssst <- supported_summary_statistic_types()
  ss_list <- list()
  for(i in seq_along(ssst)){
    ss_list[[ssst[i]]] <- try(read_reference_posterior_summary_statistic(x = x$reference_posterior_name, pdb = pdb(x), type = ssst[i]), silent = TRUE)
    if(inherits(ss_list[[ssst[i]]], "try-error")) ss_list[[ssst[i]]] <- NULL
  }
  ss_list
}
