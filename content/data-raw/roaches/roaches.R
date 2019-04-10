

unzip("roaches.csv.zip")
roaches <- read.csv("roaches.csv")

roaches_json <- list(N = nrow(roaches),
                     roach1 = roaches$roach1,
                     senior = roaches$senior,
                     treatment = roaches$treatment,                     
                     exposure2 = roaches$exposure2,
                     y = roaches$y)

writeLines(jsonlite::toJSON(roaches_json, pretty = TRUE, auto_unbox = TRUE), con = "roaches.json")
zip(zipfile = "roaches.json.zip", files = "roaches.json")
