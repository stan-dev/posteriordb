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
