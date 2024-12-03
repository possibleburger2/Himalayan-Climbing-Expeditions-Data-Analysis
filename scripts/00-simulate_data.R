#### Preamble ####
# Purpose: Simulates polling data
# Author: Daniel Xu
# Date: 4 November 2024
# Contact: danie.xu@mail.utoronto..ca
# License: MIT



#### Workspace setup ####
library(tidyverse)
library(unmarked)
set.seed(853)

# Number of Observations
n_peaks <- 10
n_members <- 100
n_expeditions <- 10
# Simulation parameters 
Average_height <- 6100  # height in meters
Tallest_peak <- 8849 # We can easily include the highest peak, since we know the tallest part of the tallest mountain,
 #but since the lowest peak of a mountain must be 1000 feet up from its base, it is difficult to determine the lowest peak in the Himalayas
#create List of Peaks along with corresponding peak id
peakid <- c()
peakname <- c()
peaks <- data.frame(
  peak_id = sample()
)
#create Weighted list of Seasons
seasons <- c("Spring","Summer", "Autumn", "Winter")#weighted since people more often do ascents during warmer seasons/seasons with calmer weather
seasons_prob <- c(0.35,0.2,0.35,0.1)

#simulate Expeditions
n_expeditions <- 500
expedition <- data.frame(
  expedition_id = 1:n_expeditions,
  peak_id = sample(peaks, n_expeditions, replace = TRUE),
  peak_name = peaks$peak_name[match(sample(peaks$peak_id, n_expeditions, replace = TRUE), peaks$peak_id)],
  year = sample(1950:2023, n_expeditions, replace = TRUE),
  season = sample(c("Spring", "Summer", "Autumn", "Winter"), n_expeditions, replace = TRUE),
  basecamp_date = as.Date("2023-01-01") + sample(0:10000, n_expeditions, replace = TRUE),
  highpoint_date = as.Date("2023-01-01") + sample(0:10000, n_expeditions, replace = TRUE),
  termination_date = as.Date("2023-01-01") + sample(0:10000, n_expeditions, replace = TRUE),
  termination_reason = sample(c("Success", "Weather", "Health", "Avalanche", "Other"), n_expeditions, replace = TRUE),
  highpoint_metres = sample(5000:9000, n_expeditions, replace = TRUE),
  members = sample(2:20, n_expeditions, replace = TRUE),
  member_deaths = sample(0:5, n_expeditions, replace = TRUE),
  hired_staff = sample(1:10, n_expeditions, replace = TRUE),
  hired_staff_deaths = sample(0:2, n_expeditions, replace = TRUE),
  oxygen_used = sample(c(TRUE, FALSE), n_expeditions, replace = TRUE),
  trekking_agency = sample(c("Agency A", "Agency B", "Agency C", "None"), n_expeditions, replace = TRUE)
)
#Simulate Peaks
peaks <- defdata(varname= "height_meters",dist = "beta",)
Peaks <- matrix(NA,npeaks,1)

gfg = seq(3000,1) # Despite their being many low peaks in the Himalayas, Overall the Himalayas starts at a high sea level, and most peaks climbed
               # are usually taller
dbeta(npeaks,7,3)


#### Save data ####
#write_csv(analysis_data, "data/00-simulated_data/simulated_data.csv")
