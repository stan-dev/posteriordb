verified_checks <- c(
  "ndraws_is_10k", "r_hat_below_1_01", "efmi_above_0_2",
  "abs_mean_lag1_ac_below_0_05"
)

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

# Recompute the quality checks reported in checks_made.
check_diagnostic_thresholds <- function(diagnostics, checks_made) {
  missing_checks <- setdiff(verified_checks, names(checks_made))
  errors <- character()
  if (length(missing_checks)) {
    errors <- c(
      errors,
      paste0(
        "'checks_made' is missing checks: ",
        paste(missing_checks, collapse = ", ")
      )
    )
  }

  numeric_values <- function(field) {
    values <- unlist(diagnostics[[field]], use.names = FALSE)
    if (!is.numeric(values) || !length(values) || any(!is.finite(values))) {
      return(NULL)
    }
    values
  }

  ndraws <- diagnostics$ndraws
  if (!is.numeric(ndraws) || length(ndraws) != 1L ||
      !is.finite(ndraws) || ndraws != 10000) {
    errors <- c(errors, "'ndraws_is_10k' failed: 'ndraws' must equal 10000")
  }

  r_hat <- numeric_values("r_hat")
  if (is.null(r_hat) || !all(r_hat < 1.01)) {
    errors <- c(
      errors,
      "'r_hat_below_1_01' failed: all 'r_hat' values must be below 1.01"
    )
  }

  efmi <- numeric_values("expected_fraction_of_missing_information")
  if (is.null(efmi) || !all(efmi > 0.2)) {
    errors <- c(
      errors,
      "'efmi_above_0_2' failed: all E-FMI values must be above 0.2"
    )
  }

  lag1_ac <- numeric_values("mean_lag1_ac")
  if (is.null(lag1_ac) || !all(abs(lag1_ac) < 0.05)) {
    errors <- c(
      errors,
      paste0(
        "'abs_mean_lag1_ac_below_0_05' failed: all absolute ",
        "'mean_lag1_ac' values must be below 0.05"
      )
    )
  }

  errors
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
    checks_to_verify <- intersect(verified_checks, names(info$checks_made))
    if (length(checks_to_verify)) {
      passed <- vapply(
        info$checks_made[checks_to_verify],
        identical,
        logical(1),
        y = TRUE
      )
      if (!all(passed)) {
        errors <- c(
          errors,
          paste0(
            "checks must be true: ",
            paste(checks_to_verify[!passed], collapse = ", ")
          )
        )
      }
    }
  }
  if (is.list(info$diagnostics) && is.list(info$checks_made)) {
    errors <- c(
      errors,
      check_diagnostic_thresholds(info$diagnostics, info$checks_made)
    )
  }

  errors
}
