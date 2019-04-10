
eightschools <- list(J = 8L,
                     y = as.integer(c(28, 8, -3, 7, -1, 1, 18, 12)),
                     sigma = as.integer(c(15, 10, 16, 11, 9, 11, 10, 18)))

jsonlite::write_json(jsonlite::toJSON(eightschools, pretty = TRUE), path = "8schools.json")
zip(zipfile = "8schools.json.zip", files = "8schools.json")