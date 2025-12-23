# ============================================================
# Nomogram generation (RMS) for Hybrid Model
# Manuscript: Dual-Layer Spectral CT-Based Models for the Differential Diagnosis of Breast Lesions
# R: 4.4.1
# ============================================================

suppressPackageStartupMessages({
  library(rms)
  library(readxl)
  library(dplyr)
})

# -------------------------
# Config (portable paths)
# -------------------------
DATA_PATH <- file.path("data", "newdata11.xlsx")     # change if needed
OUTPUT_DIR <- file.path("outputs")
OUT_FIG <- file.path(OUTPUT_DIR, "Figure_Nomogram_FINAL.tiff")
OUT_COEF <- file.path(OUTPUT_DIR, "Hybrid_Nomogram_Coefficients_R.csv")

if (!dir.exists(OUTPUT_DIR)) dir.create(OUTPUT_DIR, recursive = TRUE)

# -------------------------
# Load data
# -------------------------
if (!file.exists(DATA_PATH)) {
  stop("Input file not found: ", DATA_PATH,
       "\nPlease place the de-identified Excel file at: ", normalizePath(dirname(DATA_PATH), mustWork = FALSE))
}

df_raw <- read_excel(DATA_PATH)

# -------------------------
# Harmonize column names (optional but reviewer-safe)
# -------------------------
# Prefer consistent naming with the Python pipeline / tables
if ("Tumor size" %in% names(df_raw) && !("Tumor size (mm)" %in% names(df_raw))) {
  names(df_raw)[names(df_raw) == "Tumor size"] <- "Tumor size (mm)"
}

required_cols <- c("Breast lesion", "Shape", "Enhancement degree", "Margin", "Tumor size (mm)", "VNZeff")
missing_cols <- setdiff(required_cols, names(df_raw))
if (length(missing_cols) > 0) {
  stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
}

# -------------------------
# Build analysis dataset (explicit checks)
# -------------------------
df_nomogram0 <- df_raw %>%
  transmute(
    Breast.lesion = as.integer(`Breast lesion`),
    Shape = as.integer(Shape),
    Enhancement.degree = as.integer(`Enhancement degree`),
    Margin = as.integer(Margin),
    Tumor.size = suppressWarnings(as.numeric(`Tumor size (mm)`)),
    VNZeff = suppressWarnings(as.numeric(VNZeff))
  )

# Validate outcome coding (reviewer-proof)
if (any(is.na(df_nomogram0$Breast.lesion))) stop("Outcome contains NA after conversion.")
u_y <- sort(unique(df_nomogram0$Breast.lesion))
if (!all(u_y %in% c(0, 1))) {
  stop("Outcome must be coded as 0/1. Found values: ", paste(u_y, collapse = ", "))
}

# Validate categorical encodings (0/1/2)
if (any(!df_nomogram0$Shape %in% c(0, 1), na.rm = TRUE)) {
  stop("Shape must be coded as 0/1. Found invalid values.")
}
if (any(!df_nomogram0$Enhancement.degree %in% c(0, 1, 2), na.rm = TRUE)) {
  stop("Enhancement degree must be coded as 0/1/2. Found invalid values.")
}
if (any(!df_nomogram0$Margin %in% c(0, 1, 2), na.rm = TRUE)) {
  stop("Margin must be coded as 0/1/2. Found invalid values.")
}

n_before <- nrow(df_nomogram0)

df_nomogram <- df_nomogram0 %>%
  mutate(
    Shape = factor(Shape, levels = c(0, 1), labels = c("Regular", "Irregular")),
    Enhancement.degree = factor(Enhancement.degree, levels = c(0, 1, 2), labels = c("Light", "Moderate", "Marked")),
    Margin = factor(Margin, levels = c(0, 1, 2), labels = c("Circumscribed", "Irregular", "Spiculated"))
  ) %>%
  na.omit()

n_after <- nrow(df_nomogram)
message("Nomogram dataset: n = ", n_after, " (dropped ", n_before - n_after, " rows due to missing values)")

if (n_after < 20) {
  warning("Very small sample size after NA omission. Please verify missingness handling.")
}

# -------------------------
# datadist (required by rms)
# -------------------------
dd <- datadist(df_nomogram)
options(datadist = "dd")

# -------------------------
# Fit logistic model (for nomogram visualization)
# -------------------------
fit <- lrm(
  Breast.lesion ~ Shape + Enhancement.degree + Margin + Tumor.size + VNZeff,
  data = df_nomogram,
  x = TRUE,
  y = TRUE
)

# Save coefficients (reviewer-friendly)
coef_df <- data.frame(
  Term = names(coef(fit)),
  Coefficient = as.numeric(coef(fit)),
  row.names = NULL
)
write.csv(coef_df, OUT_COEF, row.names = FALSE)

# -------------------------
# Nomogram (linear predictor scale)
# -------------------------
nom <- nomogram(
  fit,
  fun = NULL,
  lp = TRUE,
  funlabel = "Linear predictor (logit scale)"
)

# -------------------------
# Save figure (TIFF, 600 dpi)
# -------------------------
tiff(OUT_FIG, width = 10, height = 8, units = "in", res = 600, compression = "lzw")

plot(
  nom,
  xfrac = 0.48,
  lmgp  = 0.30,
  cex.axis = 0.9,
  cex.var  = 1.0,
  main = "Hybrid Nomogram for Differentiating Breast Lesions"
)

dev.off()

message("Saved nomogram figure: ", OUT_FIG)
message("Saved coefficients table: ", OUT_COEF)
