# Load packages ----------------------------------------------------------------

library(tidyverse)

# Fetch data -------------------------------------------------------------------

ecdc_raw <- read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv")

# Save data --------------------------------------------------------------------

write_csv(ecdc_raw, "data/ecdc.csv")
