# Instrumental Variable Regression Analysis
# Overview

This project demonstrates how to analyze the effect of education on wages using OLS and instrumental variable (IV) regression methods. The analysis uses data from Estonia and implements both manual two-stage least squares (2SLS) and automated IV regression functions in R. It also includes statistical tests to evaluate the validity and strength of instruments.

# 1. Data Preparation

Loads the dataset from a public CSV file.

Filters observations for Estonia with positive wages and complete data on key variables.

Transforms the wage variable into logarithmic form.

Samples 90% of the dataset for the analysis.

# 2. Ordinary Least Squares (OLS) Regression

Estimates a baseline linear regression model of log wages on age, gender, education, and weekly hours.

Interprets the estimated effect of education on wages.

Presents results in a stargazer-like table for clarity.

# 3. Manual Two-Stage Least Squares (2SLS)

First stage: Regresses education on potential instruments (father’s education, mother’s education, number of books) and other covariates.

Performs an F-test to check for weak instruments.

Calculates predicted values and residuals for use in the second stage.

Second stage: Regresses log wages on predicted education values and other covariates.

Confirms that IV estimates differ from OLS estimates in the expected direction.

Tests residuals to verify statistical significance.

# 4. Instrumental Variable Regression Using ivreg

Implements IV regression using ivreg() from the AER package.

Uses father’s education, mother’s education, and number of books as instruments.

Compares IV estimates with the manually computed 2SLS results.

Finds that education increases wages by approximately 20% in the IV model.

# 5. Instrument Validity and Diagnostic Tests

F-test for weak instruments confirms instruments are relevant.

Wu-Hausman test compares OLS and IV estimates to check for endogeneity.

Sargan test assesses overidentifying restrictions to verify instrument exogeneity.

Identifies that the number of books may be an invalid instrument, while parental education instruments are valid.

Key Findings

OLS estimates of the education effect are biased downward due to endogeneity.

IV estimates correct for endogeneity, showing a larger effect of education on wages.

Not all instruments are valid; careful selection is critical for consistent estimation.

Economic interpretation: Parental education strongly affects children’s education, but individual wage outcomes vary depending on job choice and sector.

Tools and Packages Used

tidyverse / dplyr – Data manipulation and filtering

stargazer – Presentation of regression tables

AER / ivmodel / sandwich / survival / zoo – Instrumental variable regression and diagnostics
