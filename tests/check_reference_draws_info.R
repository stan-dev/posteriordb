# Check that each parameter-level diagnostic has one value per parameter.
check_diagnostic_lengths <- function(diagnostics) {
  diagnostic_fields <- c(
    "diagnostic_information", "effective_sample_size_bulk",
    "effective_sample_size_tail", "r_hat", "mean_lag1_ac"
  )
  missing_fields <- setdiff(diagnostic_fields, names(diagnostics))
  if (length(missing_fields)) {
    return(paste0(
      "'diagnostics' is missing fields: ",
      paste(missing_fields, collapse = ", ")
    ))
  }

  diagnostic_information <- diagnostics$diagnostic_information
  if (!is.list(diagnostic_information) ||
      !is.list(diagnostic_information$names)) {
    return("'diagnostic_information.names' must be a list")
  }
  parameter_names <- diagnostic_information$names

  value_fields <- diagnostic_fields[-1]
  invalid_lists <- value_fields[!vapply(
    diagnostics[value_fields], is.list, logical(1)
  )]
  if (length(invalid_lists)) {
    return(paste0(
      "diagnostic fields must be lists: ",
      paste(invalid_lists, collapse = ", ")
    ))
  }

  expected_length <- length(parameter_names)
  actual_lengths <- lengths(diagnostics[value_fields])
  mismatched <- value_fields[actual_lengths != expected_length]
  if (length(mismatched)) {
    return(vapply(mismatched, function(field) {
      paste0(
        "'", field, "' must have ", expected_length,
        " entries; found ", actual_lengths[[field]]
      )
    }, character(1)))
  }

  character()
}

# Check that each chain-level diagnostic has one value per chain.
check_chain_diagnostic_lengths <- function(diagnostics) {
  value_fields <- c(
    "divergent_transitions",
    "expected_fraction_of_missing_information"
  )
  required_fields <- c("nchains", value_fields)
  missing_fields <- setdiff(required_fields, names(diagnostics))
  if (length(missing_fields)) {
    return(paste0(
      "'diagnostics' is missing fields: ",
      paste(missing_fields, collapse = ", ")
    ))
  }

  nchains <- diagnostics$nchains
  if (!is.numeric(nchains) || length(nchains) != 1L ||
      !is.finite(nchains) || nchains < 0 || nchains != as.integer(nchains)) {
    return("'nchains' must be a non-negative integer")
  }

  invalid_lists <- value_fields[!vapply(
    diagnostics[value_fields], is.list, logical(1)
  )]
  if (length(invalid_lists)) {
    return(paste0(
      "chain diagnostic fields must be lists: ",
      paste(invalid_lists, collapse = ", ")
    ))
  }

  actual_lengths <- lengths(diagnostics[value_fields])
  mismatched <- value_fields[actual_lengths != nchains]
  if (length(mismatched)) {
    return(vapply(mismatched, function(field) {
      paste0(
        "'", field, "' must have ", nchains,
        " entries; found ", actual_lengths[[field]]
      )
    }, character(1)))
  }

  character()
}

# Check the required structure and identity of a draws info file.
check_draws_info <- function(path) {
  info <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  if (!is.list(info) || is.null(names(info))) {
    return("must contain a JSON object")
  }

  required_fields <- c(
    "name", "inference", "diagnostics", "checks_made", "comments",
    "added_by", "added_date", "versions"
  )
  missing_fields <- setdiff(required_fields, names(info))
  expected_name <- sub("\\.info\\.json$", "", basename(path))
  errors <- character()

  if (length(missing_fields)) {
    errors <- c(
      errors,
      paste0("missing required fields: ", paste(missing_fields, collapse = ", "))
    )
  }
  if (is.null(info$name) || !identical(info$name, expected_name)) {
    errors <- c(errors, paste0("'name' must be '", expected_name, "'"))
  }
  if (!is.list(info$inference) ||
      !all(c("method", "method_arguments") %in% names(info$inference)) ||
      !is.character(info$inference$method) ||
      length(info$inference$method) != 1L ||
      !nzchar(info$inference$method) ||
      !is.list(info$inference$method_arguments)) {
    errors <- c(errors, "'inference' must contain method and method_arguments")
  }

  object_fields <- c("diagnostics", "checks_made", "versions")
  invalid_objects <- object_fields[!vapply(
    info[object_fields], is.list, logical(1)
  )]
  if (length(invalid_objects)) {
    errors <- c(
      errors,
      paste0("fields must be JSON objects: ", paste(invalid_objects, collapse = ", "))
    )
  }
  if (is.list(info$diagnostics)) {
    errors <- c(
      errors,
      check_diagnostic_lengths(info$diagnostics),
      check_chain_diagnostic_lengths(info$diagnostics)
    )
  }
  if (is.list(info$checks_made) && !is.null(names(info$checks_made))) {
    if (!length(info$checks_made)) {
      errors <- c(errors, "'checks_made' must contain at least one check")
    } else {
      passed <- vapply(info$checks_made, identical, logical(1), y = TRUE)
      if (!all(passed)) {
        errors <- c(
          errors,
          paste0(
            "checks must be true: ",
            paste(names(info$checks_made)[!passed], collapse = ", ")
          )
        )
      }
    }
  }

  errors
}
