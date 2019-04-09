library(stringr)

# Unzip and read in data
unzip("srrs2.dat.zip")
unzip("cty.dat.zip")
cty <- read.table("cty.dat", sep = ",", header = TRUE)
srrs2 <- read.table("srrs2.dat", sep = ",", header = TRUE)

# Clean data.
srrs2$fips <- 1000 * srrs2$stfips + srrs2$cntyfips
cty$fips <- 1000 * cty$stfips + cty$ctfips
srrs2 <- merge(srrs2, cty[, c("fips", "Uppm")], by = "fips")
srrs2 <- srrs2[!duplicated(srrs2$idnum),]
srrs2_mn <- srrs2[srrs2$state == "MN",]
srrs2$log_radon <- log(srrs2$activity + 0.1)

# Finalize datasets
log_radon <- srrs2$log_radon
floor_measure <- srrs2$floor
log_uppm <- log(srrs2$Uppm + 0.1)
county <- stringr::str_trim(as.character(srrs2$county))
mn_bool <- srrs2$state == "MN" # Minnesota subset

radon <-  list(N = length(log_radon),
               J = length(levels(as.factor(county))),
               floor_measure = floor_measure,
               log_radon = log_radon,
               log_uppm = log_uppm,
               county_idx = as.integer(as.factor(county)))

radon_mn <-  list(N = length(log_radon[mn_bool]),
                 J = length(levels(as.factor(county[mn_bool]))),
                 floor_measure = floor_measure[mn_bool],
                 log_radon = log_radon[mn_bool],
                 log_uppm = log_uppm[mn_bool],
                 county_idx = county[mn_bool])

jsonlite::write_json(jsonlite::toJSON(radon), path = "radon.json")
zip(zipfile = "radon.json.zip", files = "radon.json")
jsonlite::write_json(jsonlite::toJSON(radon_mn), path = "radon_mn.json")
zip(zipfile = "radon_mn.json.zip", files = "radon_mn.json")

