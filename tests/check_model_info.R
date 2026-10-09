# Validate a model metadata file and its declared implementations.
check_model_info <- function(path, database_directory = "posterior_database") {
  info <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  if (!is.list(info) || is.null(names(info))) {
    return("must contain a JSON object")
  }

  required_fields <- c(
    "name", "keywords", "title", "description", "urls",
    "model_implementations", "references", "added_date", "added_by",
    "licence"
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

  nonempty_character_fields <- c(
    "name", "title", "description", "added_by", "licence"
  )
  invalid_character_fields <- nonempty_character_fields[!vapply(
    info[nonempty_character_fields],
    function(value) {
      is.character(value) && length(value) == 1L && nzchar(value)
    },
    logical(1)
  )]
  if (length(invalid_character_fields)) {
    errors <- c(
      errors,
      paste0(
        "fields must be non-empty strings: ",
        paste(invalid_character_fields, collapse = ", ")
      )
    )
  }

  if (!is.character(info$added_date) || length(info$added_date) != 1L ||
      is.na(as.Date(info$added_date, format = "%Y-%m-%d")) ||
      format(as.Date(info$added_date, format = "%Y-%m-%d"), "%Y-%m-%d") !=
        info$added_date) {
    errors <- c(errors, "'added_date' must be a valid YYYY-MM-DD date")
  }

  implementations <- info$model_implementations
  if (!is.list(implementations) || !length(implementations) ||
      is.null(names(implementations)) || any(!nzchar(names(implementations)))) {
    return(c(
      errors,
      "'model_implementations' must be a non-empty JSON object"
    ))
  }

  for (language in names(implementations)) {
    implementation <- implementations[[language]]
    label <- paste0("model_implementations.", language)
    if (!is.list(implementation) || is.null(names(implementation))) {
      errors <- c(errors, paste0("'", label, "' must be a JSON object"))
      next
    }

    model_code <- implementation$model_code
    if (!is.character(model_code) || length(model_code) != 1L ||
        !nzchar(model_code)) {
      errors <- c(errors, paste0("'", label, ".model_code' must be a string"))
    } else {
      expected_prefix <- paste0("models/", language, "/")
      if (!startsWith(model_code, expected_prefix)) {
        errors <- c(
          errors,
          paste0("'", label, ".model_code' must start with '", expected_prefix, "'")
        )
      }
      model_path <- file.path(database_directory, model_code)
      if (!file.exists(model_path)) {
        errors <- c(
          errors,
          paste0("referenced model code does not exist: ", model_path)
        )
      }
    }

    version_field <- paste0(language, "_version")
    version <- implementation[[version_field]]
    if (!is.character(version) || length(version) != 1L || !nzchar(version)) {
      errors <- c(
        errors,
        paste0("'", label, ".", version_field, "' must be a non-empty string")
      )
    }
  }

  errors
}
