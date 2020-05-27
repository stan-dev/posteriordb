suppressPackageStartupMessages(library(EnvStats))
remotes::install_github("https://github.com/MansMeg/covid19model", subdir = "rpackage")
library(covid19model)

start_time <- Sys.time()

## Reading all data
data(country_data)
serial.interval <- read.csv("serial_interval.csv")
serial_interval <- c(serial.interval$fit, rep(0, 100))

# Read in daily_data from cfg
data("icv3_0514")
daily_data <- icv3_0514

# Remove Finland
daily_data <- daily_data[daily_data$country != "Finland",]
country_data <- country_data[country_data$country != "Finland",]
lvls <- levels(daily_data$country)[-15]
daily_data$country <- factor(as.character(daily_data$country), levels = lvls)

# Parameters
N2 = 100 # increase if you need more forecast
date_min <- as.Date("2020-01-01")
date_max <- as.Date("2020-05-01")
# Change to as.Date("2020-04-01") to create ecdc0401

# Extract dates in analysis
daily_data <- daily_data[daily_data$date <= date_max,]

# Replace missing values with 0
daily_data$cases[is.na(daily_data$cases)] <- 0
daily_data$deaths[is.na(daily_data$deaths)] <- 0

assert_daily_data(daily_data)


set.seed(4711)
# various distributions required for modeling
mean1 = 5.1; cv1 = 0.86; # infection to onset
mean2 = 18.8; cv2 = 0.45 # onset to death
x1 = EnvStats::rgammaAlt(1e7,mean1,cv1) # infection-to-onset distribution
x2 = EnvStats::rgammaAlt(1e7,mean2,cv2) # onset-to-death distribution

ecdf.saved = ecdf(x1+x2)


# Note that the Stan model already includes an intercept
formula_from_cfg <- eval(parse(text = "~ schools...universities + self.isolating.if.ill + public.events + any.intervention + lockdown + social.distancing.encouraged"))
stan_data <- covid19_stan_data(formula = formula_from_cfg,
                               formula_hiearchical = NULL,
                               daily_data = daily_data,
                               country_data = country_data,
                               serial_interval = serial_interval,
                               ecdf_time = ecdf.saved,
                               N0 = 6,
                               N2 = N2)
stan_data$hiearchical <- NULL
save(stan_data, file = "ecdc0501.rda")
# Change to save(stan_data, file = "ecdc0401.rda") to create ecdc0401
