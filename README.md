# Dual-Layer Spectral CT–Based Models for Differentiating Breast Lesions

This repository contains the complete analysis code used in the study  
**“Dual-Layer Spectral CT-Based Models for the Differential Diagnosis of Breast Lesions”**,  
submitted to a peer-reviewed radiology journal.

The code implements a transparent machine learning pipeline designed to minimize
information leakage during feature selection, model development, validation, and
performance evaluation, in accordance with the methodological descriptions reported
in the manuscript.

---

## Overview of the Study

This retrospective study aimed to develop and validate diagnostic models for
differentiating benign from malignant breast lesions incidentally detected on chest
CT examinations using:

- Clinico-radiological features  
- Dual-layer spectral CT (DSCT) quantitative parameters  
- A hybrid model integrating both feature types  

All modeling procedures were designed to **minimize overfitting and prevent
information leakage**.

---

## Analysis Environment

- **Python**: 3.9  
- **R**: 4.4.1 (used exclusively for nomogram construction and visualization)  

Key Python packages include:
- numpy, pandas, scipy  
- scikit-learn  
- statsmodels  
- matplotlib, seaborn  

---

## Dataset and Privacy Statement

- The dataset consists of **retrospective clinical and imaging-derived variables**
  from patients who underwent clinically indicated chest DSCT examinations.
- **No raw imaging data or patient identifiers are included** in this repository.
- All analyses were performed on de-identified tabular data in accordance with
  institutional review board approval.
- Due to privacy regulations, the original dataset is **not publicly shared**.

The absence of publicly shared data does not affect the reproducibility of the
analytical workflow, as all data preprocessing, feature selection, model development,
and validation steps are fully documented and executable with appropriately formatted
input data.

---

## Data Partitioning Strategy

To prevent overfitting and information leakage, the cohort was split using
**stratified sampling**:

- **Training set**: ~70%  
- **Validation set**: ~14%  
- **Independent testing set**: ~16%  

Key principles:
- The **testing set was strictly held out** and used *only* for final performance
  reporting.
- **Feature selection, collinearity assessment, and model fitting were conducted
  exclusively within the training set**.
- The validation set was used for intermediate model comparison, not for final
  inference.

---

## Code Structure

The analysis pipeline is organized into four sequential modules.

---

### **MODULE 1 – Data Preparation and Univariate Analysis**

- Data loading and column harmonization  
- Train / validation / test splitting  
- Univariate statistical analysis (training set only)  
- Automatic selection of statistical tests:
  - Shapiro–Wilk normality test  
  - Levene test  
  - Student’s t-test / Welch’s t-test / Mann–Whitney U test  
  - Chi-square test / Fisher’s exact test  
- Generation of:
  - Table 2 (clinical and morphological features)  
  - Table 3 (DSCT parameters)  
  - Supplementary Tables S2–S4 (univariable ROC analysis)  
  - Parameter-level ROC curves  

---

### **MODULE 2 – Collinearity Assessment and Feature Selection**

- Pearson correlation filtering (|r| > 0.7)  
- Variance inflation factor (VIF) filtering (VIF > 5)  
- LASSO regression with:
  - Five-fold cross-validation  
  - One–standard-error criterion (λ₁se)  
- Independent feature selection for:
  - Clinico-radiological model  
  - DSCT-based model  
  - Hybrid model  
- Generation of:
  - Pearson correlation heatmaps  
  - VIF bar plots  
  - LASSO cross-validation curves  
  - LASSO coefficient paths  
  - Supplementary Tables S5–S9  

---

### **MODULE 3 – Model Development and Validation**

- Logistic regression models constructed using LASSO-selected features  
- Model evaluation performed on:
  - Training set (apparent performance)  
  - Validation set  
  - Independent testing set  
- Performance metrics:
  - AUC with 95% confidence intervals (bootstrap resampling)  
  - Sensitivity and specificity  
  - Accuracy  
  - Matthews correlation coefficient (MCC)  
  - Optimal cutoff values (Youden index)  
- Model robustness assessed via **nested cross-validation**:
  - Outer loop: 5 folds  
  - Inner loop: 5 folds  
  - Feature selection and model fitting repeated within each iteration  
- Generation of publication-grade figures:
  - ROC curves  
  - Calibration curves  
  - Decision curve analysis (DCA)  
  - All figures labeled and formatted for journal submission  

---

### **MODULE 4 – Final Hybrid Nomogram Construction**

- Final logistic regression model constructed using hybrid LASSO-selected predictors  
- Explicit dummy coding with fixed reference categories  
- Extraction of model coefficients  
- Generation of:
  - Final nomogram formula  
  - Supplementary coefficient table for interpretability  

---

## Reproducibility Notes

- All random processes use a fixed random seed (`RANDOM_STATE = 2025`).  
- All feature selection steps are **nested within appropriate resampling frameworks**.  
- The pipeline follows commonly recommended practices for medical prediction modeling,
  including strict separation of training, validation, and testing data.

---

## Intended Use

This repository is provided for:
- Methodological transparency  
- Peer review and editorial evaluation  
- Academic reproducibility and educational reference  

The code is **not intended for direct clinical deployment** without external validation
and regulatory approval.

---

## Citation

If you find this code useful, please cite the associated manuscript when available.

---

## Contact

For questions regarding the analysis pipeline or methodology, please contact the
corresponding author.
