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
  library(MASS)
  library(pROC)
  set.seed(42)  
  
  #### Read the data and create model ####
  
  expeditions <- read_parquet("data/02-analysis_data/expeditions_analysis_data.parquet")
  members <- read_parquet("data/02-analysis_data/members_analysis_data.parquet")
  peaks <- read_parquet("data/02-analysis_data/peaks_analysis_data.parquet")
  
  
  
  
  #split data for testing
  
  data_split <- initial_split(expeditions, prop = 0.8)
  
  # Extract the training and testing data
  train_data <- training(data_split)
  test_data <- testing(data_split)
  
  # Optionally, you can check the split
  nrow(train_data)  # Training data size
  nrow(test_data)   # Testing data size
  
  
  
  
  model <- glm(formula = success ~ average_age + members + hired_staff + oxygen_used + season 
                + height_attempted + year + previous_attempts + sex_ratio,
                data = test_data,
                family = "binomial")
  
  summary(model)
  
  model3 <- stepAIC(model)
  model2 <- glm(formula = success ~ average_age + members  + oxygen_used
               + height_attempted + previous_attempts,
               data = test_data,
               family = "binomial")
  summary(model2)
  
  test_data$predicted_prob <- predict(model2,newdata = test_data, type = "response")
  test_data$predicted_class <- ifelse(test_data$predicted_prob >= 0.5, 1, 0)
  
  # Evaluate model performance
  # Confusion matrix
  confusion_matrix <- table(Predicted = test_data$predicted_class, Actual = test_data$success)
  print(confusion_matrix)
  
  # Calculate accuracy
  accuracy <- sum(diag(confusion_matrix)) / sum(confusion_matrix)
  print(paste("Accuracy:", accuracy))
  
  roc_curve <- roc(test_data$success, test_data$predicted_prob)
  
  # Plot the ROC curve
  plot(roc_curve, col = "blue", main = "ROC Curve", print.auc = TRUE)
  
  # Optionally, get the AUC value
  auc_value <- auc(roc_curve)
  print(paste("AUC:", auc_value))
  
  #### Save model ####
  saveRDS(
    model,
    file = "models/model1.rds"
  )
  saveRDS(
    model2,
    file = "models/model2.rds"
  )
  
