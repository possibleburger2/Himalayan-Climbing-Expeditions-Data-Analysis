#### Preamble ####
# Purpose: Tests analysis data
# Author: Daniel
# Date: 4 November 2024
# Contact: danie.xu@mail.utoronto.ca
# License: MIT



#### Workspace setup ####
library(tidyverse)
library(testthat)
library(arrow)
library(here)

members <- read_parquet(here("data/00-simulated_data/simulated_members.parquet"))
expedition <- read_parquet(here("data/00-simulated_data/simulated_expeditions.parquet"))
peaks <- read_parquet(here("data/00-simulated_data/simulated_peaks.parquet"))

# Expedition tests
# Test 1: No missing critical fields in expedition
if (any(is.na(expedition$expedition_id))) stop("Missing values in expedition_id")
if (any(is.na(expedition$peak_id))) stop("Missing values in peak_id")
if (any(is.na(expedition$year))) stop("Missing values in year")

# Test 2: Expedition years are valid
if (any(expedition$year < 1905 | expedition$year > 2019)) stop("Expedition year out of range (1905-2019)")

# Test 3: Members count is reasonable
if (any(expedition$members < 0)) stop("Members count should be greater than 0")

# Peaks tests
# Test 1: Peak heights are valid
if (any(peaks$height_metres < 5000 | peaks$height_metres > 9000)) stop("Peak height out of range (5000-9000)")

# Test 2: Peak IDs are unique
if (length(unique(peaks$peak_id)) != nrow(peaks)) stop("Duplicate peak IDs found")

# Test 3: First ascent year is valid
invalid_years <- peaks$first_ascent_year[!is.na(peaks$first_ascent_year)] # Filter non-NA years

if (any(invalid_years < 1905 | invalid_years > 2019)) {
  stop("Invalid first_ascent_year found: must be NA or between 1800 and 2019")
}

# Members tests
# Test 1: Member expedition links are valid
if (!all(members$expedition_id %in% expedition$expedition_id)) stop("Invalid expedition_id in members")

# Test 2: Member IDs are valid
if (any(is.na(members$member_id))) stop("Missing member_id values")

# Test 3: Members' ages are reasonable
invalid_ages <- members$age[!is.na(members$age)]
if (any(invalid_ages < 0 | invalid_ages > 120)) stop("Members' ages out of reasonable bounds (0-120)")

# Test 4: Highpoint does not exceed peak height
#peak_heights <- peaks$height_metres[match(members$peak_id, peaks$peak_id)]
#invalid_rows <- which(members$highpoint_metres > peak_heights)
#print(invalid_rows)
#if (any(members$highpoint_metres > peak_heights)) stop("Highpoint exceeds peak height")

# Test 5: If died is TRUE, death cause should not be NA
if (any(members$died & is.na(members$death_cause))) stop("Death cause is missing for members who died")

