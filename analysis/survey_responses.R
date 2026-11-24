# Load required packages
library(tidyverse)
library(scales)

# Set directory
getwd()
setwd("C:/Users/Chrizelle/Documents/Research_Report/Analysis")

# Load the survey CSV file 
survey_data <- read_csv("var_filt_report_survey_responses.csv")

# Inspect dataset structure and summary
glimpse(survey_data)
head(survey_data)
summary(survey_data)


# ---SURVEY DATA CLEANING AND SUBSETTING---

# Subset target columns and assign clean column names
survey_subset <- survey_data %>%
  select(
    participant_id = `Participant ID`,
    
    # Section 2 Filters - Text Ratings (Cols 6 to 13)
    text_2.1_consequences  = 6,
    text_2.2_african_af    = 7,
    text_2.3_allele_freq   = 8,
    text_2.4_quality_ab    = 9,
    text_2.5_hom_ref       = 10,
    text_2.6_pred_scores   = 11,
    text_2.7_empty_var     = 12,
    text_2.8_cand_genes    = 13,
    
    # Section 2 Filters - Visual/Graphic Ratings (Cols 14 to 21)
    vis_2.1_consequences   = 14,
    vis_2.2_african_af     = 15,
    vis_2.3_allele_freq    = 16,
    vis_2.4_quality_ab     = 17,
    vis_2.5_hom_ref        = 18,
    vis_2.6_pred_scores    = 19,
    vis_2.7_empty_var      = 20,
    vis_2.8_cand_genes     = 21,
    
    # Downstream Confidence Assessment
    confidence_downstream  = `The report provides sufficient confidence to pass these filtered variants downstream to additional filtering and variant interpretation.`
  )

# Inspect raw data values and column structures
cat("--- SUBSET GLIMPSE ---\n")
glimpse(survey_subset)

cat("\n--- RAW VALUES HEAD ---\n")
head(survey_subset, 5)

# Filter out Participant 1, parse numeric ratings (1–5), and standardize confidence
survey_cleaned <- survey_subset %>%
  filter(participant_id != 1) %>%
  mutate(across(starts_with("text_") | starts_with("vis_"), parse_number)) %>%
  mutate(confidence_downstream = factor(trimws(confidence_downstream)))

# Map clean labels and reshape to long format
filter_step_labels <- c(
  "2.1_consequences" = "2.1 Consequences",
  "2.2_african_af"   = "2.2 African AF",
  "2.3_allele_freq"  = "2.3 Allele Frequency",
  "2.4_quality_ab"   = "2.4 Quality & AB",
  "2.5_hom_ref"      = "2.5 Hom Reference",
  "2.6_pred_scores"  = "2.6 Prediction Scores",
  "2.7_empty_var"    = "2.7 Empty Variants",
  "2.8_cand_genes"   = "2.8 Candidate Genes"
)

survey_long <- survey_cleaned %>%
  pivot_longer(
    cols = starts_with("text_") | starts_with("vis_"),
    names_to = c("component", "filter_step"),
    names_pattern = "(text|vis)_(.*)",
    values_to = "rating"
  ) %>%
  mutate(
    component = if_else(component == "text", "Text Explanations", "Graphs & Visual Elements"),
    filter_step = recode(filter_step, !!!filter_step_labels)
  )

# Verify participant filtering and structure
cat("Remaining participant count:", n_distinct(survey_cleaned$participant_id), "\n\n")

cat("--- CLEANED WIDE DATASET ---\n")
glimpse(survey_cleaned)

cat("\n--- CLEANED LONG DATASET ---\n")
glimpse(survey_long)


# --- DUMBELL PLOT (RATING FILTERS RESPONSES)---

# 1. Define explicit label mapping and chronological order
filter_map <- c(
  "2.1_consequences" = "1. Consequences",
  "2.2_african_af"   = "2. African AF",
  "2.3_allele_freq"  = "3. Allele Frequency",
  "2.4_quality_ab"   = "4. Quality & AB",
  "2.5_hom_ref"      = "5. Hom Reference",
  "2.6_pred_scores"  = "6. Prediction Scores",
  "2.7_empty_var"    = "7. Empty Variants",
  "2.8_cand_genes"   = "8. Candidate Genes"
)

step_order_rev <- c(
  "8. Candidate Genes",
  "7. Empty Variants",
  "6. Prediction Scores",
  "5. Hom Reference",
  "4. Quality & AB",
  "3. Allele Frequency",
  "2. African AF",
  "1. Consequences"
)

# 2. Re-pivot survey_cleaned cleanly to ensure exact key matching
survey_long <- survey_cleaned %>%
  pivot_longer(
    cols = starts_with("text_") | starts_with("vis_"),
    names_to = c("component", "filter_key"),
    names_pattern = "(text|vis)_(.*)",
    values_to = "rating"
  ) %>%
  mutate(
    component = if_else(component == "text", "Text Explanations", "Graphs & Visual Elements"),
    filter_step = recode(filter_key, !!!filter_map)
  )

# 3. Summarize mean ratings per step
dumbbell_data <- survey_long %>%
  group_by(filter_step, component) %>%
  summarise(mean_rating = mean(rating, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = component, values_from = mean_rating) %>%
  rename(text_mean = `Text Explanations`, vis_mean = `Graphs & Visual Elements`) %>%
  mutate(filter_step = factor(filter_step, levels = step_order_rev))

# 4. Build Dumbbell Plot
p_dumbbell <- ggplot(dumbbell_data) +
  # Connecting line between Text and Visual ratings
  geom_segment(
    aes(x = text_mean, xend = vis_mean, y = filter_step, yend = filter_step),
    color = "grey75", linewidth = 1.2
  ) +
  # Text Rating Points
  geom_point(
    aes(x = text_mean, y = filter_step, color = "Text Explanations"),
    size = 4
  ) +
  # Visual Rating Points
  geom_point(
    aes(x = vis_mean, y = filter_step, color = "Graphs & Visual Elements"),
    size = 4
  ) +
  # Numeric Rating Value Labels
  geom_text(
    aes(x = text_mean, y = filter_step, label = sprintf("%.2f", text_mean)),
    vjust = -0.9, size = 3.2, color = "#2b5c8f", fontface = "bold"
  ) +
  geom_text(
    aes(x = vis_mean, y = filter_step, label = sprintf("%.2f", vis_mean)),
    vjust = 1.8, size = 3.2, color = "#d95f02", fontface = "bold"
  ) +
  scale_x_continuous(
    limits = c(1, 5),
    breaks = 1:5,
    labels = c("1\n(Poor)", "2", "3\n(Adequate)", "4", "5\n(Excellent)")
  ) +
  scale_color_manual(
    values = c("Text Explanations" = "#2b5c8f", "Graphs & Visual Elements" = "#d95f02")
  ) +
  labs(
    title = "Report Evaluation: Text Explanations vs. Visual Elements",
    subtitle = "Mean satisfaction ratings per filter step (1–5 scale)",
    x = "Mean Rating",
    y = NULL,
    color = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "top",
    panel.grid.minor = element_blank(),
    plot.title = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, color = "grey40"),
    axis.title.x = element_text(color = "grey40", margin = margin(t = 8)),
    axis.text.y = element_text(face = "bold", color = "grey20")
  )

print(p_dumbbell)

ggsave("survey_dumbbell_ordered.pdf", plot = p_dumbbell, width = 10, height = 5.5, dpi = 600)

# --- PLOT (DOWNSTREAM USE CONFIDENCE)---

# 1. Clean strings and preserve original scale levels
confidence_summary <- survey_cleaned %>%
  filter(!is.na(confidence_downstream)) %>%
  mutate(
    confidence_level = str_to_title(trimws(as.character(confidence_downstream))),
    confidence_level = factor(confidence_level, levels = c("Agree", "Neutral", "Disagree"))
  ) %>%
  filter(!is.na(confidence_level)) %>%
  count(confidence_level, .drop = FALSE) %>%
  mutate(percentage = n / sum(n))

# 2. Assign color palette matching report theme
palette_confidence <- c(
  "Agree"    = "#2b5c8f",  # Dark Blue
  "Neutral"  = "#7570b3",  # Muted Slate / Purple
  "Disagree" = "#d95f02"   # Dark Orange
)

# 3. Build Bar Chart (Headroom up to 1.15, axis ticks capped strictly at 100%)
p_confidence <- ggplot(confidence_summary, aes(x = confidence_level, y = percentage, fill = confidence_level)) +
  geom_col(width = 0.5, show.legend = FALSE) +
  geom_text(
    aes(label = ifelse(n > 0, paste0(sprintf("%.1f", percentage * 100), "%\n(n = ", n, ")"), "0%")),
    vjust = -0.3,
    size = 4,
    fontface = "bold",
    color = "grey25"
  ) +
  # Extend limits to 1.15 for text headroom, but explicitly break ticks only up to 1.0 (100%)
  scale_y_continuous(
    labels = percent_format(accuracy = 1),
    limits = c(0, 1.15),
    breaks = seq(0, 1, by = 0.25),
    expand = c(0, 0)
  ) +
  scale_fill_manual(values = palette_confidence) +
  labs(
    title = "Downstream Analysis Readiness Confidence",
    subtitle = "User agreement that report provides sufficient confidence to pass variants downstream",
    x = "Confidence Rating",
    y = "Percentage of Respondents"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(hjust = 0.5, face = "bold", margin = margin(b = 6)),
    plot.subtitle = element_text(hjust = 0.5, color = "grey40", margin = margin(b = 22)),
    axis.title = element_text(color = "grey40"),
    axis.title.x = element_text(color = "grey40", margin = margin(t = 8)),
    axis.title.y = element_text(color = "grey40", margin = margin(r = 8)),
    axis.text.x = element_text(face = "bold", size = 11, color = "grey20"),
    plot.margin = margin(t = 15, r = 15, b = 10, l = 15)
  )

# 4. Render and export
print(p_confidence)

ggsave("survey_downstream_confidence.png", plot = p_confidence, width = 7.5, height = 5, dpi = 600)


# --- COMBINE PLOTS (FOR REPORT)---

library(patchwork)
library(ggplot2)

# 1. Clean Panel A (Dumbbell Plot)
p_dumbbell_clean <- p_dumbbell + 
  theme(
    plot.title = element_blank(),
    plot.subtitle = element_blank(),
    legend.position = "top",
    plot.margin = margin(t = 10, r = 15, b = 15, l = 15)
  )

# 2. Clean Panel B (Confidence Plot) with added top headroom to prevent cutoff
p_confidence_clean <- p_confidence + 
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 1),
    limits = c(0, 1.20),            # Extends y-axis canvas to 120% for text headroom
    breaks = seq(0, 1, by = 0.25),  # Keeps tick marks capped strictly at 100%
    expand = c(0, 0)
  ) +
  coord_cartesian(clip = "off") +   # Allows text above 100% to draw outside clipping box
  theme(
    plot.title = element_blank(),
    plot.subtitle = element_blank(),
    plot.margin = margin(t = 30, r = 15, b = 10, l = 15) # Increased top margin for clearance from Panel A
  )

# 3. Combine vertically with tag levels A and B
combined_survey <- (p_dumbbell_clean / p_confidence_clean) +
  plot_layout(heights = c(1.5, 1)) +
  plot_annotation(tag_levels = 'A') &
  theme(
    plot.tag = element_text(size = 12, face = "bold")
  )

# 4. Render and save
print(combined_survey)

ggsave(
  filename = "combined_survey_vstack.pdf",
  plot = combined_survey,
  width = 8.5,
  height = 9.5,
  dpi = 600
)

