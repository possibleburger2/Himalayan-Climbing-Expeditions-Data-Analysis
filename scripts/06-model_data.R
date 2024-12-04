#### Preamble ####
# Purpose: Models winner of 2024 US election
# Author: Daniel, Vandan
# Date: 4 November 2024
# Contact: danie.xu@mail.utoronto.ca
# License: MIT


#### Workspace setup ####
library(tidyverse)
library(rstanarm)
library(here)
library(arrow)
library(brms)
  
#### Read the data and create model ####
# Read the cleaned analysis dataset
#expeditions <- read_csv("data/02-analysis_data/expeditions_analysis_data.csv")
#members <- read_csv("data/02-analysis_data/members_analysis_data.csv")
#peaks <-read_csv("data/02-analysis_data/peaks_analysis_data.csv")

members_exp <-  merge(members,expeditions,by = c("expedition_id","year","season","peak_id","peak_name"),all.x = TRUE)
total <- merge(members_exp,)
# Fit a Bayesian logistic regression model
model <- brm(
  formula = success ~ age + members + hired_staff + oxygen_used.x + season,
  data = members_exp,
  family = bernoulli(),   # Logistic regression
  prior = c(
    prior(normal(0, 5), class = "b"),   # Prior for coefficients
    prior(normal(0, 5), class = "Intercept")   # Prior for intercept
  ),
  cores = 4,      # Number of CPU cores to use for parallel processing
  control = list(adapt_delta = 0.99)   # Control for convergence issues (if needed)
)

# View model summary
summary(model)

# Check diagnostics (Rhat, effective sample size, etc.)
launch_shinystan(model)


#### Save model ####
saveRDS(
  model,
  file = "models/single_bay.rds"
)


