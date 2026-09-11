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
