# Taken from the 
url <- "http://stat.columbia.edu/~gelman/arm/examples/arsenic/wells.dat"
wells <- read.table(url)
wells$dist100 <- with(wells, dist / 100)
wells$c_dist100 <- wells$dist100 - mean(wells$dist100)
wells$c_arsenic <- wells$arsenic - mean(wells$arsenic)
wells$c_educ4 <- wells$educ/4 - mean(wells$educ/4)

X <- model.matrix(~ dist100 + arsenic, wells)
arsenic <- list(y = wells$switch, X = X, N = nrow(X), P = ncol(X))
writeLines(jsonlite::toJSON(arsenic, pretty = TRUE, auto_unbox = TRUE), con = "arsenic.json")
zip(zipfile = "arsenic.json.zip", files = "arsenic.json")

X <- model.matrix(~ dist100 + log(arsenic), wells)
arsenic <- list(y = wells$switch, X = X, N = nrow(X), P = ncol(X))
writeLines(jsonlite::toJSON(arsenic, pretty = TRUE, auto_unbox = TRUE), con = "arsenic_log.json")
zip(zipfile = "arsenic_log.json.zip", files = "arsenic_log.json")

X <- model.matrix(~ c_dist100 + c_arsenic, wells)
arsenic_latent_linear <- list(y = wells$switch, X = X, N = nrow(X), P = ncol(X))
writeLines(jsonlite::toJSON(arsenic, pretty = TRUE, auto_unbox = TRUE), con = "arsenic_base.json")
zip(zipfile = "arsenic_base.json.zip", files = "arsenic_base.json")

X <- model.matrix(~ c_dist100 + c_arsenic + c_educ4, wells)
arsenic_latent_linear <- list(y = wells$switch, X = X, N = nrow(X), P = ncol(X))
writeLines(jsonlite::toJSON(arsenic, pretty = TRUE, auto_unbox = TRUE), con = "arsenic_linear.json")
zip(zipfile = "arsenic_latent_linear.json.zip", files = "arsenic_linear.json")

X <- model.matrix(~ c_dist100 + c_arsenic + c_educ4 +
                    c_dist100:c_educ4 + c_arsenic:c_educ4, wells)
arsenic_latent_linear <- list(y = wells$switch, X = X, N = nrow(X), P = ncol(X))
writeLines(jsonlite::toJSON(arsenic, pretty = TRUE, auto_unbox = TRUE), con = "arsenic_linear_interaction.json")
zip(zipfile = "arsenic_linear_interaction.json.zip", files = "arsenic_linear_interaction.json")

