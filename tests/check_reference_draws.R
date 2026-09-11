# Reference-draw data and companion info directories.
reference_draws_directory <- file.path(
  "posterior_database", "reference_posteriors", "draws"
)
reference_paths <- list(
  draws = file.path(reference_draws_directory, "draws"),
  info = file.path(reference_draws_directory, "info")
)
source("tests/check_reference_draws_zip.R")
source("tests/check_reference_draws_info.R")

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

# Find each draw archive's companion info file.
info_files_for_draws <- function(paths) {
  draw_names <- sub("\\.json\\.zip$", "", basename(paths))
  file.path(reference_paths$info, paste0(draw_names, ".info.json"))
}

# Find each info file's companion draw archive.
draw_files_for_info <- function(paths) {
  draw_names <- sub("\\.info\\.json$", "", basename(paths))
  file.path(reference_paths$draws, paste0(draw_names, ".json.zip"))
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

# Discover added files once, then select draw archives and info files.
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
added_info_files <- filter_files(
  paths = added_files,
  directory = reference_paths$info,
  pattern = "\\.info\\.json$"
)
if (!length(zip_files) && !length(added_info_files)) {
  message("No newly added reference-draw files to check.")
  quit(status = 0L)
}

# Additional draw-archive checks can be added to this list later.
draw_zip_checks <- list(check_draws_zip)
info_file_checks <- list(check_draws_info)
info_files <- unique(c(
  added_info_files,
  info_files_for_draws(zip_files)
))
failures <- c(
  run_file_checks(zip_files, draw_zip_checks),
  run_file_checks(info_files, info_file_checks),
  run_file_checks(draw_files_for_info(added_info_files), list())
)

if (length(failures)) {
  stop(
    "Invalid reference-draw file(s):\n- ",
    paste(failures, collapse = "\n- "),
    call. = FALSE
  )
}

message(
  "Checked ", length(zip_files), " new reference-draw ZIP file(s) and ",
  length(added_info_files), " new info file(s)."
)
