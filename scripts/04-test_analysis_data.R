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

members <- read_parquet(here("data/02-analysis_data/members_analysis_data.parquet"))
expedition <- read_parquet(here("data/02-analysis_data/expedition_analysis_data.parquet"))
peaks <- read_parquet(here("data/02-analysis_data/peaks_analysis_data.parquet"))

# Expedition tests
# Test 1: No missing critical fields in expedition
if (any(is.na(expedition$expedition_id))) stop("Missing values in expedition_id")
if (any(is.na(expedition$peak_id))) stop("Missing values in peak_id")
if (any(is.na(expedition$year))) stop("Missing values in year")

# Test 2: Expedition years are valid
if (any(expedition$year < 1905 | expedition$year > 2019)) stop("Expedition year out of range (1905-2019)")

# Test 3: Members count is reasonable
if (any(expedition$members <= 0)) stop("Members count should be greater than 0")

# Peaks tests
# Test 1: Peak heights are valid
if (any(peaks$peak_height < 5000 | peaks$peak_height > 9000)) stop("Peak height out of range (5000-9000)")

# Test 2: Peak IDs are unique
if (length(unique(peaks$peak_id)) != nrow(peaks)) stop("Duplicate peak IDs found")

# Test 3: First ascent year is valid
if (any(peaks$first_ascent_year < 1800 | peaks$first_ascent_year > 2019)) stop("First ascent year out of range (1800-2019)")

# Members tests
# Test 1: Member expedition links are valid
if (!all(members$expedition_id %in% expedition$expedition_id)) stop("Invalid expedition_id in members")

# Test 2: Member IDs are valid
if (any(is.na(members$member_id))) stop("Missing member_id values")

# Test 3: Members' ages are reasonable
if (any(members$age < 18 | members$age > 80)) stop("Members' ages out of reasonable bounds (18-80)")

# Test 4: Highpoint does not exceed peak height
peak_heights <- peaks$peak_height[match(members$peak_id, peaks$peak_id)]
if (any(members$highpoint_metres > peak_heights)) stop("Highpoint exceeds peak height")

# Test 5: If died is TRUE, death cause should not be NA
if (any(members$died & is.na(members$death_cause))) stop("Death cause is missing for members who died")

