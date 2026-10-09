# Directories containing the metadata checked for newly added files.
database_directory <- "posterior_database"
model_info_directory <- file.path(database_directory, "models", "info")
reference_draws_directory <- file.path(
  database_directory, "reference_posteriors", "draws"
)
summary_statistics_directory <- file.path(
  database_directory, "reference_posteriors", "summary_statistics"
)
reference_paths <- list(
  draws = file.path(reference_draws_directory, "draws"),
  info = file.path(reference_draws_directory, "info")
)
source("tests/check_reference_draws_zip.R")
source("tests/check_reference_draws_info.R")
source("tests/check_model_info.R")
source("tests/check_summary_statistics_info.R")

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

# Find each summary statistic's companion info file, and vice versa.
info_files_for_summary_statistics <- function(paths) {
  vapply(paths, function(path) {
    statistic_directory <- dirname(dirname(path))
    statistic_name <- sub("\\.json$", "", basename(path))
    file.path(statistic_directory, "info", paste0(statistic_name, ".info.json"))
  }, character(1), USE.NAMES = FALSE)
}

summary_statistic_files_for_info <- function(paths) {
  vapply(paths, function(path) {
    statistic_directory <- dirname(dirname(path))
    statistic <- basename(statistic_directory)
    posterior_name <- sub("\\.info\\.json$", "", basename(path))
    file.path(
      statistic_directory,
      statistic,
      paste0(posterior_name, ".json")
    )
  }, character(1), USE.NAMES = FALSE)
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

# Discover added files once, then select the supported metadata and archives.
added_files <- get_added_files(
  base_sha = args[[1]],
  head_sha = args[[2]],
  directory = database_directory
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
model_info_files <- filter_files(
  paths = added_files,
  directory = model_info_directory,
  pattern = "\\.info\\.json$"
)
summary_info_files <- added_files[
  startsWith(added_files, paste0(summary_statistics_directory, "/")) &
    grepl("/info/[^/]+\\.info\\.json$", added_files)
]
summary_statistic_files <- added_files[
  startsWith(added_files, paste0(summary_statistics_directory, "/")) &
    grepl("\\.json$", added_files) &
    !grepl("\\.info\\.json$", added_files)
]
summary_statistic_files <- summary_statistic_files[vapply(
  summary_statistic_files,
  function(path) basename(dirname(path)) == basename(dirname(dirname(path))),
  logical(1)
)]
if (!length(zip_files) && !length(added_info_files) &&
    !length(model_info_files) && !length(summary_info_files) &&
    !length(summary_statistic_files)) {
  message("No newly added model or reference-posterior info files to check.")
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
  run_file_checks(draw_files_for_info(added_info_files), list()),
  run_file_checks(
    model_info_files,
    list(function(path) check_model_info(path, database_directory))
  ),
  run_file_checks(summary_info_files, list(check_summary_statistics_info)),
  run_file_checks(
    summary_statistic_files_for_info(summary_info_files),
    list()
  ),
  run_file_checks(
    info_files_for_summary_statistics(summary_statistic_files),
    list(check_summary_statistics_info)
  )
)

if (length(failures)) {
  stop(
    "Invalid submitted metadata or reference-draw file(s):\n- ",
    paste(failures, collapse = "\n- "),
    call. = FALSE
  )
}

message(
  "Checked ", length(zip_files), " reference-draw ZIP file(s), ",
  length(added_info_files), " draw info file(s), ",
  length(model_info_files), " model info file(s), and ",
  length(unique(c(
    summary_info_files,
    info_files_for_summary_statistics(summary_statistic_files)
  ))), " summary-statistic info file(s)."
)
