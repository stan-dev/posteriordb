
eightschools <- list(J = 8L,
                     y = as.integer(c(28, 8, -3, 7, -1, 1, 18, 12)),
                     sigma = as.integer(c(15, 10, 16, 11, 9, 11, 10, 18)))

writeLines(jsonlite::toJSON(eightschools, pretty = TRUE, auto_unbox = TRUE), con = "8_schools.json")
zip(zipfile = "8_schools.json.zip", files = "8_schools.json")

data_info <- list(title = jsonlite::unbox("The 8 schools dataset of Rubin (1981)"),
                  description = jsonlite::unbox("A study for the Educational Testing Service to analyze the effects of
special coaching programs on test scores. See Gelman et. al. (2014), Section 5.5 for details."),
                  urls = character(0),
                  references = c("Rubin (1981)", "Gelman et. al. (2014)"),
                  keywords = "bda3_example")
jsonlite::write_json(data_info, "8_schools.info.json", pretty = TRUE)
