#### Preamble ####
# Purpose: Tests analysis data
# Author: Daniel, Vandan
# Date: 4 November 2024
# Contact: danie.xu@mail.utoronto.ca
# License: MIT



#### Workspace setup ####
library(testthat)
library(tidyverse)
library(testthat)
library(arrow)

data <- read_parquet("data/02-analysis_data/analysis_data.csv")

test_that("Critical columns do not contain NA", {
  expect_true(all(!is.na(expedition$expedition_id)))
  expect_true(all(!is.na(expedition$peak_id)))
  expect_true(all(!is.na(peaks$peak_id)))
  expect_true(all(!is.na(members$expedition_id)))
})

test_that("Year is within a valid range", {
  expect_true(all(expedition$year >= 1900 & expedition$year <= 2023))
  expect_true(all(members$year >= 1900 & members$year <= 2023))
})

test_that("Peak heights are within plausible ranges", {
  expect_true(all(peaks$height_metres >= 6000 & peaks$height_metres <= 9000))
})

test_that("Death cause and height are filled when died is TRUE", {
  expect_true(all(is.na(members$death_cause[!members$died]) | members$died[!members$died] == FALSE))
  expect_true(all(is.na(members$death_height_metres[!members$died]) | members$died[!members$died] == FALSE))
})

test_that("Highpoint metres do not exceed peak height", {
  for (i in 1:nrow(expedition)) {
    peak_height <- peaks$height_metres[peaks$peak_id == expedition$peak_id[i]]
    expect_true(expedition$highpoint_metres[i] <= peak_height)
  }
  
  for (i in 1:nrow(members)) {
    peak_height <- peaks$height_metres[peaks$peak_id == members$peak_id[i]]
    expect_true(members$highpoint_metres[i] <= peak_height)
  }
})

test_that("Members have valid expedition IDs", {
  expect_true(all(members$expedition_id %in% expedition$expedition_id))
})

test_that("There are successful expeditions", {
  expect_gt(sum(expedition$termination_reason == "Success"), 0)
})

test_file("test_simulated_data.R")
# Apply rules to data
validation_results <- confront(data, rules)

# Summary of validation
summary(validation_results)

