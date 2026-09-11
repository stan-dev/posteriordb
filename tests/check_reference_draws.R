# Reference-draw data and companion info directories.
reference_draws_directory <- file.path(
  "posterior_database", "reference_posteriors", "draws"
)
reference_paths <- list(
  draws = file.path(reference_draws_directory, "draws"),
  info = file.path(reference_draws_directory, "info")
)

# Get files added between the PR base and head commits.
get_added_files <- function(base_sha, head_sha, directory) {
  output <- system2(
    "git",
    c(
      "diff", "--name-only", "--diff-filter=A",
      base_sha, head_sha, "--", directory
    ),
    stdout = TRUE,
    stderr = TRUE
  )

  status <- attr(output, "status")
  if (!is.null(status) && status != 0L) {
    stop("Could not determine the files changed by this pull request:\n",
         paste(output, collapse = "\n"))
  }

  output
}

# Select files in a directory that match a filename pattern.
filter_files <- function(paths, directory, pattern) {
  paths[
    startsWith(paths, paste0(directory, "/")) &
      grepl(pattern, paths)
  ]
}

# Require one JSON file and reject common archive metadata.
check_draws_zip <- function(path) {
  entries <- utils::unzip(path, list = TRUE)$Name
  files <- entries[!grepl("/$", entries)]
  basenames <- basename(entries)
  metadata <- grepl("(^|/)__MACOSX(/|$)", entries) |
    basenames == ".DS_Store" |
    startsWith(basenames, "._")

  errors <- character()
  if (any(metadata)) {
    errors <- c(
      errors,
      paste0("contains metadata: ", paste(entries[metadata], collapse = ", "))
    )
  }
  if (length(files) != 1L || !grepl("\\.json$", files)) {
    errors <- c(
      errors,
      paste0(
        "must contain exactly one JSON file; found: ",
        if (length(files)) paste(files, collapse = ", ") else "no files"
      )
    )
  }

  errors
}

# Run each check on each file and collect readable failures.
run_file_checks <- function(paths, checks) {
  unlist(lapply(paths, function(path) {
    if (!file.exists(path)) {
      return(paste0(path, ": file does not exist"))
    }

    errors <- unlist(lapply(checks, function(check) {
      tryCatch(
        check(path),
        error = function(error) {
          paste0("could not inspect file: ", conditionMessage(error))
        }
      )
    }), use.names = FALSE)

    if (!length(errors)) {
      return(character())
    }
    paste0(path, ": ", errors)
  }), use.names = FALSE)
}

# Read the base and head commit hashes supplied by GitHub Actions.
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) {
  stop("Usage: Rscript tests/check_reference_draws.R <base-sha> <head-sha>")
}

# Discover added files once, then select the draw archives to check.
added_files <- get_added_files(
  base_sha = args[[1]],
  head_sha = args[[2]],
  directory = reference_draws_directory
)
zip_files <- filter_files(
  paths = added_files,
  directory = reference_paths$draws,
  pattern = "\\.json\\.zip$"
)
if (!length(zip_files)) {
  message("No newly added reference-draw ZIP files to check.")
  quit(status = 0L)
}

# Additional draw-archive checks can be added to this list later.
draw_zip_checks <- list(check_draws_zip)
failures <- run_file_checks(zip_files, draw_zip_checks)

if (length(failures)) {
  stop(
    "Invalid reference-draw archive(s):\n- ",
    paste(failures, collapse = "\n- "),
    call. = FALSE
  )
}

message("Checked ", length(zip_files), " reference-draw ZIP file(s).")
