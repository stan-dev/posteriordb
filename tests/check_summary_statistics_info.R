# Convert either a JSON scalar or array to an atomic vector.
summary_info_values <- function(value) {
  unlist(value, recursive = TRUE, use.names = FALSE)
}

# Validate metadata accompanying a reference-posterior summary statistic.
check_summary_statistics_info <- function(path) {
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

  inference <- info$inference
  if (!is.list(inference) ||
      !all(c("method", "method_arguments") %in% names(inference)) ||
      !is.character(inference$method) || length(inference$method) != 1L ||
      !nzchar(inference$method) || !is.list(inference$method_arguments)) {
    errors <- c(errors, "'inference' must contain method and method_arguments")
  }

  object_fields <- c("diagnostics", "checks_made", "versions")
  invalid_objects <- object_fields[!vapply(
    info[object_fields],
    function(value) is.list(value) && !is.null(names(value)),
    logical(1)
  )]
  if (length(invalid_objects)) {
    errors <- c(
      errors,
      paste0("fields must be JSON objects: ", paste(invalid_objects, collapse = ", "))
    )
  }
  if (!is.list(info$diagnostics)) {
    return(errors)
  }

  diagnostics <- info$diagnostics
  # Both spellings occur in existing posteriordb metadata.
  diagnostic_information <- diagnostics$diagnostic_information
  if (is.null(diagnostic_information)) {
    diagnostic_information <- diagnostics$diagnostics_information
  }
  diagnostic_fields <- c(
    "effective_sample_size_bulk", "effective_sample_size_tail", "r_hat",
    "mean_lag1_ac"
  )
  chain_fields <- c(
    "divergent_transitions", "expected_fraction_of_missing_information"
  )
  missing_diagnostics <- setdiff(
    c("ndraws", "nchains", diagnostic_fields, chain_fields),
    names(diagnostics)
  )
  if (length(missing_diagnostics)) {
    errors <- c(
      errors,
      paste0(
        "'diagnostics' is missing fields: ",
        paste(missing_diagnostics, collapse = ", ")
      )
    )
  }

  if (!is.list(diagnostic_information) ||
      is.null(diagnostic_information$names)) {
    errors <- c(
      errors,
      "'diagnostic_information.names' or 'diagnostics_information.names' is required"
    )
  } else {
    parameter_names <- summary_info_values(diagnostic_information$names)
    if (!is.character(parameter_names) || !length(parameter_names) ||
        any(!nzchar(parameter_names))) {
      errors <- c(errors, "diagnostic parameter names must be non-empty strings")
    } else {
      lengths_found <- vapply(
        diagnostics[intersect(diagnostic_fields, names(diagnostics))],
        function(value) length(summary_info_values(value)),
        integer(1)
      )
      mismatched <- names(lengths_found)[lengths_found != length(parameter_names)]
      if (length(mismatched)) {
        errors <- c(
          errors,
          vapply(mismatched, function(field) {
            paste0(
              "'", field, "' must have ", length(parameter_names),
              " entries; found ", lengths_found[[field]]
            )
          }, character(1))
        )
      }
    }
  }

  scalar_nonnegative_integer <- function(value) {
    is.numeric(value) && length(value) == 1L && is.finite(value) &&
      value >= 0 && value == as.integer(value)
  }
  if (!scalar_nonnegative_integer(diagnostics$ndraws)) {
    errors <- c(errors, "'diagnostics.ndraws' must be a non-negative integer")
  }
  if (!scalar_nonnegative_integer(diagnostics$nchains)) {
    errors <- c(errors, "'diagnostics.nchains' must be a non-negative integer")
  } else {
    chain_lengths <- vapply(
      diagnostics[intersect(chain_fields, names(diagnostics))],
      function(value) length(summary_info_values(value)),
      integer(1)
    )
    mismatched <- names(chain_lengths)[chain_lengths != diagnostics$nchains]
    if (length(mismatched)) {
      errors <- c(
        errors,
        vapply(mismatched, function(field) {
          paste0(
            "'", field, "' must have ", diagnostics$nchains,
            " entries; found ", chain_lengths[[field]]
          )
        }, character(1))
      )
    }
  }

  numeric_diagnostic <- function(field) {
    values <- summary_info_values(diagnostics[[field]])
    if (!is.numeric(values) || !length(values) || any(!is.finite(values))) {
      return(NULL)
    }
    values
  }
  checks <- info$checks_made
  verify_check <- function(name, passed, failure) {
    if (!is.list(checks) || is.null(checks[[name]])) {
      return(character())
    }
    if (!identical(checks[[name]], TRUE)) {
      return(paste0("'checks_made.", name, "' must be true"))
    }
    if (!isTRUE(passed)) failure else character()
  }

  r_hat <- numeric_diagnostic("r_hat")
  efmi <- numeric_diagnostic("expected_fraction_of_missing_information")
  lag1_ac <- numeric_diagnostic("mean_lag1_ac")
  divergences <- numeric_diagnostic("divergent_transitions")
  errors <- c(
    errors,
    verify_check(
      "ndraws_is_10k", identical(diagnostics$ndraws, 10000L) ||
        identical(diagnostics$ndraws, 10000),
      "'ndraws_is_10k' failed: 'diagnostics.ndraws' must equal 10000"
    ),
    verify_check(
      "ndraws_is_gte_10k", is.numeric(diagnostics$ndraws) &&
        length(diagnostics$ndraws) == 1L && diagnostics$ndraws >= 10000,
      "'ndraws_is_gte_10k' failed: 'diagnostics.ndraws' must be at least 10000"
    ),
    verify_check(
      "nchains_is_gte_4", is.numeric(diagnostics$nchains) &&
        length(diagnostics$nchains) == 1L && diagnostics$nchains >= 4,
      "'nchains_is_gte_4' failed: 'diagnostics.nchains' must be at least 4"
    ),
    verify_check(
      "r_hat_below_1_01", !is.null(r_hat) && all(r_hat < 1.01),
      "'r_hat_below_1_01' failed: all 'r_hat' values must be below 1.01"
    ),
    verify_check(
      "efmi_above_0_2", !is.null(efmi) && all(efmi > 0.2),
      "'efmi_above_0_2' failed: all E-FMI values must be above 0.2"
    ),
    verify_check(
      "abs_mean_lag1_ac_below_0_05",
      !is.null(lag1_ac) && all(abs(lag1_ac) < 0.05),
      paste0(
        "'abs_mean_lag1_ac_below_0_05' failed: all absolute ",
        "'mean_lag1_ac' values must be below 0.05"
      )
    ),
    verify_check(
      "no_divergences", !is.null(divergences) && all(divergences == 0),
      "'no_divergences' failed: all divergent-transition counts must be zero"
    )
  )

  errors
}
