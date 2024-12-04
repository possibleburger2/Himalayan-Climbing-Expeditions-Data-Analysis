#### Preamble ####
# Purpose: Simulates polling data
# Author: Daniel Xu
# Date: 4 November 2024
# Contact: danie.xu@mail.utoronto..ca
# License: MIT



#### Workspace setup ####
library(tidyverse)
library(unmarked)
library(arrow)
set.seed(853)

# Number of Observations
n_peaks <- 20
n_members <- 100
n_expeditions <- 10
# Simulation parameters

Average_height <- 6100  # height in meters
Tallest_peak <- 8849 # We can easily include the highest peak, since we know 
#the tallest part of the tallest mountain,
#but since the lowest peak of a mountain must be 1000 feet up from its base, 
#it is difficult to determine the lowest peak in the Himalayas

#create Weighted list of Seasons
seasons <- c("Spring", "Summer", "Autumn", "Winter")#weighted since people more 
#often do ascents during warmer seasons/seasons with calmer weather
seasons_prob <- c(0.35, 0.2, 0.35, 0.1)

#create List of Peaks along with corresponding peak id and height
peaks <- data.frame(
  peak_id = 1:20,  # Hypothetical unique IDs
  peak_name = c(
    "Everest", "K2", "Kangchenjunga", "Lhotse", "Makalu",
    "Cho Oyu", "Dhaulagiri", "Manaslu", "Annapurna I", "Gasherbrum I",
    "Broad Peak", "Gasherbrum II", "Shishapangma", "Nanga Parbat", 
    "Annapurna II", "Annapurna III", "Annapurna IV", "Langtang Lirung", 
    "Ganesh I", "Pumori"
  ),
  peak_alt = c("Sagarmatha", "Chhogori", NA, "E1", "Kamalung", NA, NA , NA, NA,
               "Hidden Peak", NA, NA, "Gosainthan", "Diamir", NA, NA, NA, NA, 
               NA, "Everest's Daughter"),
  peak_height = (5000 + 4000 * rbeta(n_peaks,2,5)),
  climbing_status = sample(c("Climbed", "Unclimbed"), n_peaks, 
                           replace = TRUE, prob = c(0.8,0.2)),
  first_ascent_year = sample(1905:2019, n_peaks, replace = TRUE),
  first_ascent_country = sample(c("Nepal", "India", "China", "USA", "UK"),
                      n_peaks, replace = TRUE, prob = c(0.4,0.2,0.2,0.1,0.1)),
  first_ascent_expedition_id = paste0(gsub(" ", "", c(
    "Everest", "K2", "Kangchenjunga", "Lhotse", "Makalu",
    "Cho Oyu", "Dhaulagiri", "Manaslu", "Annapurna I", "Gasherbrum I",
    "Broad Peak", "Gasherbrum II", "Shishapangma", "Nanga Parbat", 
    "Annapurna II", "Annapurna III", "Annapurna IV", "Langtang Lirung", 
    "Ganesh I", "Pumori"
  )), sample(1000:9999, n_peaks, replace = TRUE))  # Random number between 1000 and 9999
)


#simulate Expeditions
n_expeditions <- 500
expeditions <- data.frame(
  expedition_id = 1:n_expeditions,
  peak_id = sample(peaks$peak_id, n_expeditions, replace = TRUE),
  peak_name = peaks$peak_name[match(sample(peaks$peak_id, n_expeditions, 
                                           replace = TRUE), peaks$peak_id)],
  year = sample(1905:2019, n_expeditions, replace = TRUE),
  season = sample(c("Spring", "Summer", "Autumn", "Winter"), n_expeditions, 
                  replace = TRUE,prob = seasons_prob),
  basecamp_date = as.Date("2023-01-01") + 
    sample(0:10000, n_expeditions, replace = TRUE),
  highpoint_date = as.Date("2023-01-01") + 
    sample(0:10000, n_expeditions, replace = TRUE),
  termination_date = as.Date("2023-01-01") + 
  sample(0:10000, n_expeditions, replace = TRUE),
  termination_reason = sample(c("Success", "Weather", "Health", 
                          "Avalanche", "Other"), n_expeditions, replace = TRUE),
  highpoint_metres = sample(5000:9000, n_expeditions, replace = TRUE),
  members = sample(2:20, n_expeditions, replace = TRUE),
  member_deaths = sample(0:5, n_expeditions, replace = TRUE),
  hired_staff = sample(1:10, n_expeditions, replace = TRUE),
  hired_staff_deaths = sample(0:2, n_expeditions, replace = TRUE),
  oxygen_used = sample(c(TRUE, FALSE), n_expeditions, replace = TRUE),
  trekking_agency = sample(c("Agency A", "Agency B", "Agency C", "None"),
                           n_expeditions, replace = TRUE)
)
# Simulate 'members' data

members <- data.frame(
  expedition_id = sample(expeditions$expedition_id, n_members, replace = TRUE),
  member_id = 1:n_members,
  peak_id = sample(peaks$peak_id, n_members, replace = TRUE),
  peak_name = peaks$peak_name[match(sample(peaks$peak_id, n_members,
                                           replace = TRUE), peaks$peak_id)],
  year = sample(1905:2019, n_members, replace = TRUE),
  season = sample(c("Spring", "Summer", "Autumn", "Winter"),
                  n_members, replace = TRUE),
  sex = sample(c("Male", "Female"), n_members, replace = TRUE),
  age = sample(18:70, n_members, replace = TRUE),
  citizenship = sample(c("Nepal", "India", "USA", "UK", "China"),
                       n_members, replace = TRUE),
  expedition_role = sample(c("Leader", "Climber", "Sherpa", "Support"),
                           n_members, replace = TRUE),
  hired = sample(c(TRUE, FALSE), n_members, replace = TRUE),
  highpoint_metres = sample(5000:9000, n_members, replace = TRUE),
  success = sample(c(TRUE, FALSE), n_members, replace = TRUE),
  solo = sample(c(TRUE, FALSE), n_members, replace = TRUE),
  oxygen_used = sample(c(TRUE, FALSE), n_members, replace = TRUE),
  died = sample(c(TRUE, FALSE), n_members, replace = TRUE),
  death_cause = sample(c("Avalanche", "Fall", "Altitude Sickness", "Other", NA),
                       n_members, replace = TRUE),
  death_height_metres = ifelse(runif(n_members) < 0.1, 
                               sample(5000:9000, n_members, replace = TRUE), NA),
  injured = sample(c(TRUE, FALSE), n_members, replace = TRUE),
  injury_type = sample(c("Fracture", "Frostbite", "Altitude Sickness", "Other", NA),
                       n_members, replace = TRUE),
  injury_height_metres = ifelse(runif(n_members) < 0.1, sample(5000:9000,
                                                               n_members, replace = TRUE), NA)
)
#### Save data ####
write_parquet(members, "data/00-simulated_data/simulated_members.parquet")
write_parquet(expeditions, "data/00-simulated_data/simulated_expeditions.parquet")
write_parquet(peaks, "data/00-simulated_data/simulated_peaks.parquet")


