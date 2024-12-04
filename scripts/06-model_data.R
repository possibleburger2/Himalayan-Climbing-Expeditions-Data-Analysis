#### Preamble ####
# Purpose: Models climbing successes
# Author: Daniel
# Date: 4 November 2024
# Contact: danie.xu@mail.utoronto.ca
# License: MIT


#### Workspace setup ####
library(tidyverse)
library(rstanarm)
library(here)
library(arrow)
library(brms)
library(rsample)
library(stats)

set.seed(42)  

#### Read the data and create model ####

expeditions <- read_parquet("data/02-analysis_data/expeditions_analysis_data.parquet")
members <- read_parquet("data/02-analysis_data/members_analysis_data.parquet")
peaks <- read_parquet("data/02-analysis_data/peaks_analysis_data.parquet")

#merge data

members_exp <-  merge(members,expeditions,by = c("expedition_id","year","season","peak_id","peak_name"),all.x = TRUE)
total <- merge(members_exp,peaks, by = c("peak_id","peak_name"))

#split data for testing

data_split <- initial_split(total, prop = 0.8)

# Extract the training and testing data
train_data <- training(data_split)
test_data <- testing(data_split)

# Optionally, you can check the split
nrow(train_data)  # Training data size
nrow(test_data)   # Testing data size

# Fit a Bayesian logistic regression model
model <- glm(
  formula = success ~ age + members + hired_staff + oxygen_used.x + season + height_metres + citizenship + sex,
  data = test_data,
  family = "binomial")

summary(model)

# model with hired_staff and citizenship removed 
model2 <- glm(formula = success ~ age + members + oxygen_used.x + season +height_metres + sex,
              data = test_data,
              family = "binomial")

anova(model2,model,
      test = "LRT")

round(exp(cbind(OR = coef(model2), confint(model2))), 3) # OR and 95% CI


#### Save model ####
saveRDS(
  model2,
  file = "models/binary_logit.rds"
)

saveRDS(
  model,
  file= "models/original_model.rds"
)

