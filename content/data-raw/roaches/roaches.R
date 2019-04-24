unzip("roaches.csv.zip")
roaches <- read.csv("roaches.csv")

roaches_json <- list(N = nrow(roaches),
                     y = roaches$y,
                     exposure2 = roaches$exposure2,
                     roach1 = roaches$roach1,
                     treatment = roaches$treatment,
                     senior = roaches$senior)

writeLines(jsonlite::toJSON(roaches_json, pretty = TRUE, auto_unbox = TRUE), con = "roaches.json")
zip(zipfile = "roaches.json.zip", files = "roaches.json")

roaches_scaled_json <- list(N = nrow(roaches),
                     y = roaches$y,
                     exposure2 = roaches$exposure2,
                     roach1 = as.vector(scale(roaches$roach1, center = TRUE, scale = TRUE)),
                     treatment = roaches$treatment,
                     senior = roaches$senior)

writeLines(jsonlite::toJSON(roaches_json, pretty = TRUE, auto_unbox = TRUE), con = "roaches_scaled.json")
zip(zipfile = "roaches_scaled.json.zip", files = "roaches_scaled.json")
