# Taken from the 
url <- "http://stat.columbia.edu/~gelman/arm/examples/arsenic/wells.dat"
wells <- read.table(url)
wells$dist100 <- with(wells, dist / 100)
X <- model.matrix(~ dist100 + arsenic, wells)
arsenic <- list(y = wells$switch, X = X, N = nrow(X), P = ncol(X))
writeLines(jsonlite::toJSON(arsenic, pretty = TRUE, auto_unbox = TRUE), con = "arsenic.json")
zip(zipfile = "arsenic.json.zip", files = "arsenic.json")

X <- model.matrix(~ dist100 + log(arsenic), wells)
arsenic <- list(y = wells$switch, X = X, N = nrow(X), P = ncol(X))
writeLines(jsonlite::toJSON(arsenic, pretty = TRUE, auto_unbox = TRUE), con = "arsenic_log.json")
zip(zipfile = "arsenic_log.json.zip", files = "arsenic_log.json")


