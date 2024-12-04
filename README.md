# Himalayan Climbing Expeditions Data Analysis

## Overview

This repository analysis Himalayan Climbing Expedition Data to find success odds based off a variety of factors:

The raw data was downloaded from the following repository: https://github.com/tacookson/data/tree/master/himalayan-expeditions
## File structure overview
├── data
│   ├── 00-simulated_data  
│   │   ├── simulated_expeditions.parquet  # Simulated data for expeditions.
│   │   ├── simulated_members.parquet      # Simulated data for members participating in expeditions.
│   │   └── simulated_peaks.parquet        # Simulated data for peaks being climbed.
│   ├── 01-raw_data  
│   │   ├── exped.csv                      # Raw expedition data.
│   │   ├── members.csv                    # Raw data of expedition members.
│   │   ├── peaks.csv                      # Raw data of peaks.
│   │   └── refer.csv                      # Reference file for data mapping or lookup.
│   └── 02-analysis_data  
│       ├── expeditions_analysis_data.parquet  # Processed expedition data for analysis.
│       ├── members_analysis_data.parquet      # Processed member data for analysis.
│       └── peaks_analysis_data.parquet        # Processed peaks data for analysis.
├── models  
│   ├── binary_logit.rds                   # Saved binary logistic regression model.
│   └── original_model.rds                 # Initial model before tuning or analysis.
├── other  
│   ├── modelcard  
│   │   └── model_card.md                  # Documentation of the model’s purpose, data, and usage.
│   └── sketches  
│       ├── Expedition_data_Sketch.png    # Sketch or diagram visualizing expedition data structure.
│       ├── Members_data_Sketch.png       # Sketch or diagram visualizing members' data structure.
│       └── Peaks_data_Sketch.png         # Sketch or diagram visualizing peaks data structure.
├── paper  
│   ├── image1.png                         # Supporting image for the paper.
│   ├── image2.png                         # Supporting image for the paper.
│   ├── paper.pdf                          # Final draft of the paper.
│   ├── paper.qmd                          # Quarto markdown file for the paper.
│   └── references.bib                     # Bibliography or reference file.
├── scripts  
│   ├── 00-simulate_data.R                 # Script for simulating the dataset.
│   ├── 01-test_simulated_data.R           # Script for testing the quality of simulated data.
│   ├── 03-clean_data.R                    # Script for cleaning raw data.
│   ├── 04-analyze_data.R                  # Script for analyzing processed data.
│   └── 06-merge_data.R                    # Script for merging datasets.
├── .gitignore                             # Git configuration file to ignore unnecessary files.
├── Himalayan-Climbing-Expedition.Rproj   # RStudio project file for this project.
└── README.md                              # This README file, describing the project structure.


## Statement on LLM usage

No LLMs were used for this project.
