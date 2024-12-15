#### Set-up ####
# Load libraries
library(tidyverse)
library(janitor)
library(lubridate)
library(arrow)



# Peaks
peaks <- read_csv("./data/01-raw_data/peaks.csv") %>%
  transmute(
    peak_id = PEAKID,
    peak_name = PKNAME,
    peak_alternative_name = PKNAME2,
    height_metres = HEIGHTM,
    climbing_status = PSTATUS,
    first_ascent_year = PYEAR,
    first_ascent_country = PCOUNTRY,
    first_ascent_expedition_id = PEXPID
  ) %>%
  mutate(
    climbing_status = case_when(
      climbing_status == 0 ~ "Unknown",
      climbing_status == 1 ~ "Unclimbed",
      climbing_status == 2 ~ "Climbed"
    )
  ) %>%
  # Fix data entry error for first_ascent_year for Sharpu II (SPH2)
  mutate(first_ascent_year = ifelse(peak_id == "SPH2", 2018, first_ascent_year))



# Expeditions
expeditions <- read_csv("./data/01-raw_data//exped.csv") %>%
  left_join(peak_names, by = c("PEAKID" = "peak_id")) %>%
  transmute(
    expedition_id = EXPID,
    peak_id = PEAKID,
    peak_name,
    year = YEAR,
    season = SEASON,
    termination_reason = TERMREASON,
    members = TOTMEMBERS,
    hired_staff = TOTHIRED,
    oxygen_used = O2USED,
  ) %>%
  mutate(
    termination_reason = case_when(
      termination_reason == 0 ~ "Unknown",
      termination_reason == 1 ~ "Success (main peak)",
      termination_reason == 2 ~ "Success (subpeak)",
      termination_reason == 3 ~ "Success (claimed)",
      termination_reason == 4 ~ "Bad weather (storms, high winds)",
      termination_reason == 5 ~ "Bad conditions (deep snow, avalanching, falling ice, or rock)",
      termination_reason == 6 ~ "Accident (death or serious injury)",
      termination_reason == 7 ~ "Illness, AMS, exhaustion, or frostbite",
      termination_reason == 8 ~ "Lack (or loss) of supplies or equipment",
      termination_reason == 9 ~ "Lack of time",
      termination_reason == 10 ~ "Route technically too difficult, lack of experience, strength, or motivation",
      termination_reason == 11 ~ "Did not reach base camp",
      termination_reason == 12 ~ "Did not attempt climb",
      termination_reason == 13 ~ "Attempt rumoured",
      termination_reason == 14 ~ "Other"
    ),
    season = case_when(
      season == 0 ~ "Unknown",
      season == 1 ~ "Spring",
      season == 2 ~ "Summer",
      season == 3 ~ "Autumn",
      season == 4 ~ "Winter"
    )
  )
#Expeditions <- expeditions %>%
#  mutate(expedition_id = ifelse(expedition_id == "KANG10101",""))
members <-
  read_csv("./data/01-raw_data/members.csv", guess_max = 100000) %>%
  left_join(peak_names, by = c("PEAKID" = "peak_id")) %>%
  transmute(
    expedition_id = EXPID,
    member_id = paste(EXPID, MEMBID, sep = "-"),
    peak_id = PEAKID,
    peak_name,
    year = MYEAR,
    season = MSEASON,
    sex = SEX,
    age = CALCAGE,
    citizenship = CITIZEN,
    expedition_role = STATUS,
    hired = HIRED,
    # Highpoint of 0 is most likely missing value
    highpoint_metres = ifelse(MPERHIGHPT == 0, NA, MPERHIGHPT),
    success = MSUCCESS,
    solo = MSOLO,
    oxygen_used = MO2USED,
    died = DEATH,
    death_cause = DEATHTYPE,
    # Height of 0 is most likely missing value
    death_height_metres = ifelse(DEATHHGTM == 0, NA, DEATHHGTM),
    injured = INJURY,
    injury_type = INJURYTYPE,
    # Height of 0 is most likely missing value
    injury_height_metres = ifelse(INJURYHGTM == 0, NA, INJURYHGTM)
  ) %>%
  mutate(
    season = case_when(
      season == 0 ~ "Unknown",
      season == 1 ~ "Spring",
      season == 2 ~ "Summer",
      season == 3 ~ "Autumn",
      season == 4 ~ "Winter"
    ),
    age = ifelse(age == 0, NA, age),
    death_cause = case_when(
      death_cause == 0 ~ "Unspecified",
      death_cause == 1 ~ "AMS",
      death_cause == 2 ~ "Exhaustion",
      death_cause == 3 ~ "Exposure / frostbite",
      death_cause == 4 ~ "Fall",
      death_cause == 5 ~ "Crevasse",
      death_cause == 6 ~ "Icefall collapse",
      death_cause == 7 ~ "Avalanche",
      death_cause == 8 ~ "Falling rock / ice",
      death_cause == 9 ~ "Disappearance (unexplained)",
      death_cause == 10 ~ "Illness (non-AMS)",
      death_cause == 11 ~ "Other",
      death_cause == 12 ~ "Unknown"
    ),
    injury_type = case_when(
      injury_type == 0 ~ "Unspecified",
      injury_type == 1 ~ "AMS",
      injury_type == 2 ~ "Exhaustion",
      injury_type == 3 ~ "Exposure / frostbite",
      injury_type == 4 ~ "Fall",
      injury_type == 5 ~ "Crevasse",
      injury_type == 6 ~ "Icefall collapse",
      injury_type == 7 ~ "Avalanche",
      injury_type == 8 ~ "Falling rock / ice",
      injury_type == 9 ~ "Disappearance (unexplained)",
      injury_type == 10 ~ "Illness (non-AMS)",
      injury_type == 11 ~ "Other",
      injury_type == 12 ~ "Unknown"
    ),
    death_cause = ifelse(died, death_cause, NA_character_),
    death_height_metres = ifelse(died, death_height_metres, NA),
    injury_type = ifelse(injured, injury_type, NA_character_),
    injury_height_metres = ifelse(injured, injury_height_metres, NA)
)

sex_ratios <- members |>
  group_by(expedition_id) |>
  summarize(sex_ratio = mean(sex == 'M', na.rm = TRUE)) |>  # Will give proportion of males
  ungroup()
expeditions <- expeditions |>
  left_join(sex_ratios, by = "expedition_id")


expeditions <- expeditions |>
  # Join with average age data from members
  left_join(
    members |>
      group_by(expedition_id) |>
      summarise(average_age = mean(age, na.rm = TRUE)) |>
      ungroup(),
    by = "expedition_id"
  ) |>
  # Create success column

  mutate(success = termination_reason %in% 
           c("Success (main peak)", "Success (subpeak)", "Success (claimed)")) |>
  # Create age ranges and calculate success rate
  mutate(
    age_range = cut(
      average_age,
      breaks = seq(
        from = floor(min(average_age, na.rm = TRUE)),
        to = ceiling(max(average_age, na.rm = TRUE)),
        by = 5
      ),
      labels = paste(
        seq(floor(min(average_age, na.rm = TRUE)),
            ceiling(max(average_age, na.rm = TRUE))-5,
            by = 5),
        seq(floor(min(average_age, na.rm = TRUE))+4,
            ceiling(max(average_age, na.rm = TRUE))-1,
            by = 5),
        sep = "-"
      )
    )
  ) 

height_attempted <- peaks |>
  group_by(peak_id) |>
  summarize(height_attempted = height_metres) |>  
  ungroup()
expeditions <- expeditions |>
  left_join(height_attempted, by = "peak_id")

expeditions <- expeditions |> 
  arrange(peak_id,year,season) |>
  group_by(peak_id) |>
  mutate(
    previous_attempts = row_number() - 1
  )|> 
  ungroup()

write_parquet(expeditions,"data/02-analysis_data/expeditions_analysis_data.parquet")
write_parquet(members,"data/02-analysis_data/members_analysis_data.parquet")
write_parquet(peaks,"data/02-analysis_data/peaks_analysis_data.parquet")
