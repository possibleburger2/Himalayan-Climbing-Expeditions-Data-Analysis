# Model Card: Bayesian Logistic Regression for Climbing Success Prediction

## Overview
This Bayesian logistic regression model predicts the probability of success in Himalayan climbing expeditions based on climbers' demographic and expedition characteristics. It uses historical data from expeditions, peaks, and climbers.

---

## Intended Use
### Purpose:
- Analyze factors influencing climbing success.
- Explore the significance of variables like age, oxygen use, and season in predicting summit outcomes.

### Users:
- Researchers studying mountaineering patterns.
- Policy advisors assessing safety measures for expeditions.

### Out-of-Scope Use:
- Real-time decision-making during climbs.
- Predicting success for specific individuals without accounting for real-time conditions.

---

## Data and Inputs
### Data Sources:
- **Expeditions Data:** Includes details about the expeditions (e.g., year, season).
- **Members Data:** Contains climber-specific details (e.g., age, citizenship).
- **Peaks Data:** Provides information about mountain characteristics (e.g., height in meters).

### Data Preprocessing:
1. Merged expeditions, members, and peaks datasets using shared keys (e.g., `expedition_id`, `peak_id`).
2. Split the data into training (80%) and testing (20%) subsets using `rsample::initial_split()`.

### Input Variables:
- **Predictors:** Age, members, oxygen use, season, peak height, sex.
- **Outcome Variable:** Binary indicator of success (1 = summit reached, 0 = no summit).

---

## Model Details
### Architecture:
- Bayesian logistic regression implemented in R using `glm()`.

### Training Data:
- 80% of the combined dataset (~training set size determined during preprocessing).

### Key Features:
- **Formula:** `success ~ age + members + oxygen_used.x + season + height_metres + sex`
- Two models were evaluated:
  - **Model 1:** Included hired_staff and citizenship.
  - **Model 2 (Final):** Excluded hired_staff and citizenship for improved simplicity and interpretability.

### Performance:
- **Odds Ratios (OR) and 95% Confidence Intervals (CI):** Calculated for model coefficients.
- Comparison with ANOVA test for model selection.

---

## Ethical Considerations
### Bias:
- Underrepresentation of climbers from countries with fewer expeditions may introduce bias.
- Variables like citizenship were excluded in the final model to mitigate potential ethical concerns.

### Limitations:
- Does not account for real-time weather, route conditions, or climbers’ fitness on the day of the climb.
- May generalize poorly to newer peaks with limited historical data.

---

## References
- Hawley, Elizabeth, and Richard Salisbury. *The Himalayan Database*. [himalayandatabase.com](http://www.himalayandatabase.com).
- R Core Team. (2024). R: A Language and Environment for Statistical Computing. [R Project](https://www.r-project.org/).

---

## Contact
For questions or issues, contact **Daniel Xu** at [danie.xu@mail.utoronto.ca](mailto:danie.xu@mail.utoronto.ca).
