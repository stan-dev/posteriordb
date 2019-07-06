# Taken from the 
url <- "http://stat.columbia.edu/~gelman/arm/examples/arsenic/wells.dat"
wells <- read.table(url)
wells$dist100 <- with(wells, dist / 100)
wells$c_dist100 <- wells$dist100 - mean(wells$dist100)
wells$c_arsenic <- wells$arsenic - mean(wells$arsenic)
wells$c_educ4 <- wells$educ/4 - mean(wells$educ/4)


X <- model.matrix(~ dist100 + arsenic, wells)
arsenic <- list(y = wells$switch, X = X, N = nrow(X), P = ncol(X))
writeLines(jsonlite::toJSON(arsenic, pretty = TRUE, auto_unbox = TRUE), con = "wells_noncentered.json")
zip(zipfile = "wells_noncentered.json.zip", files = "wells_noncentered.json")

X <- model.matrix(~ dist100 + log(arsenic), wells)
arsenic <- list(y = wells$switch, X = X, N = nrow(X), P = ncol(X))
writeLines(jsonlite::toJSON(arsenic, pretty = TRUE, auto_unbox = TRUE), con = "wells_noncentered_log.json")
zip(zipfile = "wells_noncentered_log.json.zip", files = "wells_noncentered_log.json")

X <- model.matrix(~ c_dist100 + c_arsenic, wells)
arsenic <- list(y = wells$switch, X = X, N = nrow(X), P = ncol(X))
writeLines(jsonlite::toJSON(arsenic, pretty = TRUE, auto_unbox = TRUE), con = "wells_centered.json")
zip(zipfile = "wells_centered.json.zip", files = "wells_centered.json")

X <- model.matrix(~ c_dist100 + c_arsenic + c_educ4, wells)
arsenic <- list(y = wells$switch, X = X, N = nrow(X), P = ncol(X))
writeLines(jsonlite::toJSON(arsenic, pretty = TRUE, auto_unbox = TRUE), con = "wells_centered_educ4.json")
zip(zipfile = "wells_centered_educ4.json.zip", files = "wells_centered_educ4.json", flags = "-j")

X <- model.matrix(~ c_dist100 + c_arsenic + c_educ4 +
                    c_dist100:c_educ4 + c_arsenic:c_educ4, wells)
arsenic <- list(y = wells$switch, X = X, N = nrow(X), P = ncol(X))
writeLines(jsonlite::toJSON(arsenic, pretty = TRUE, auto_unbox = TRUE), con = "wells_centered_educ4_interact.json")
zip(zipfile = "wells_centered_educ4_interact.json.zip", files = "wells_centered_educ4_interact.json", flags = "-j")

