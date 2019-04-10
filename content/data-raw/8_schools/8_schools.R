
eightschools <- list(J = 8L,
                     y = as.integer(c(28, 8, -3, 7, -1, 1, 18, 12)),
                     sigma = as.integer(c(15, 10, 16, 11, 9, 11, 10, 18)))

writeLines(jsonlite::toJSON(eightschools, pretty = TRUE, auto_unbox = TRUE), con = "8_schools.json")
zip(zipfile = "8_schools.json.zip", files = "8_schools.json")