Reproducibility Test
================
Chrizelle Kok
2026-11-24

## Reproducibility checks

### Purpose

The purpose of this analysis was to test whether the workflow’s results
were reproducible or not. Reproducibility in this sense is defined as
the ability to get the exact same computational results from a study
when using the same input data, parameters, and environment.

### Datasets

- ***MADCaP:*** **678,988 variants** across **212 samples** *(dataset
  M)*.
- ***DDD-Africa:*** **1,433,459 variants** across **1274 samples**
  *(dataset D)*.

### Data

We completed **three (3)** runs of the workflow on each dataset. To
comply with reproducibility requirements, the workflow was not changed
between runs and the same input file was used for each dataset. These
runs were completed at separate times. To ensure the same environment on
each execution, an **Apptainer container** was used to bundle
application code, runtimes, system tools, libraries, and dependencies
(<https://apptainer.org/documentation/>).’

We will be comparing the ***retained (PASS) files***, ***removed (FAIL)
files*** and ***report*** for each dataset.

``` r
library(tidyverse, warn.conflicts = F, quietly = T)
library(data.table, warn.conflicts = F, quietly = T)
library(rvest, warn.conflicts = F, quietly = T)
library(digest, warn.conflicts = F, quietly = T)
library(xml2, warn.conflicts = F, quietly = T)
library(writexl, warn.conflicts = F, quietly = T)
library(knitr, warn.conflicts = F, quietly = T)
library(kableExtra, warn.conflicts = F, quietly = T)
```

``` r
getwd()
setwd("C:/Users/Chrizelle/Documents/Research_Report/Analysis")
```

------------------------------------------------------------------------

## MADCaP Analysis

Report checks

``` r
# 1. Define file paths for Dataset M HTML reports across 3 runs
report_paths_m <- c(
  "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run1_2026.10.28/report/main.html",
  "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run2_2026.10.29/report/main.html",
  "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run3_2026.10.29/report/main.html"
)

# 2. Extract and sanitize HTML report content
parse_and_clean_report <- function(path) {
  page <- read_html(path)
  
  # Extract body text and strip dynamic execution metadata (timestamps, runtimes, file paths)
  raw_text <- page %>% 
    html_nodes("p, h1, h2, h3, h4, li") %>% 
    html_text(trim = TRUE)
  
  clean_text <- raw_text %>%
    grep("^$", ., invert = TRUE, value = TRUE) %>%
    gsub("\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}", "[TIMESTAMP]", .) %>%
    gsub("\\d+(\\.\\d+)?\\s*(sec|min|hours|s|m|seconds|minutes)", "[DURATION]", .) %>%
    gsub("/[A-Za-z0-9_.-]+/", "[PATH]/", .)
  
  # Extract structural data tables
  tables <- page %>% 
    html_nodes("table") %>% 
    html_table()
  
  list(text = clean_text, tables = tables)
}

# 3. Parse all 3 Dataset M reports
parsed_m <- lapply(report_paths_m, parse_and_clean_report)

# 4. Generate content checksums and compare against Run 1
text_hashes_m  <- sapply(parsed_m, function(x) digest(x$text, algo = "md5"))
table_hashes_m <- sapply(parsed_m, function(x) digest(x$tables, algo = "md5"))

report_audit_m <- tibble(
  Run = paste("Run", 1:3),
  Text_MD5 = text_hashes_m,
  Table_MD5 = table_hashes_m,
  Text_Match_Run1 = text_hashes_m == text_hashes_m[1],
  Tables_Match_Run1 = table_hashes_m == table_hashes_m[1]
)

# 5. Display comparison summary
cat("--- DATASET M: HTML REPORT REPRODUCIBILITY AUDIT ---\n\n")
```

    ## --- DATASET M: HTML REPORT REPRODUCIBILITY AUDIT ---

``` r
knitr::kable(
  report_audit_m,
  col.names = c("Run", "Text Hash (MD5)", "Table Hash (MD5)", "Text Identical (vs Run 1)", "Tables Identical (vs Run 1)"),
  caption = "Dataset M: 3x Run HTML Report Content Equivalence"
) %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"))
```

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<caption>

Dataset M: 3x Run HTML Report Content Equivalence
</caption>

<thead>

<tr>

<th style="text-align:left;">

Run
</th>

<th style="text-align:left;">

Text Hash (MD5)
</th>

<th style="text-align:left;">

Table Hash (MD5)
</th>

<th style="text-align:left;">

Text Identical (vs Run 1)
</th>

<th style="text-align:left;">

Tables Identical (vs Run 1)
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Run 1
</td>

<td style="text-align:left;">

782da25bfebb8c17f0be06bbc90cdd88
</td>

<td style="text-align:left;">

97eff1b06c6c0c1aa11965dfbe8c9f56
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

Run 2
</td>

<td style="text-align:left;">

4f5155d0c9aa335b0e395cf28553ed17
</td>

<td style="text-align:left;">

97eff1b06c6c0c1aa11965dfbe8c9f56
</td>

<td style="text-align:left;">

FALSE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

Run 3
</td>

<td style="text-align:left;">

4f5155d0c9aa335b0e395cf28553ed17
</td>

<td style="text-align:left;">

97eff1b06c6c0c1aa11965dfbe8c9f56
</td>

<td style="text-align:left;">

FALSE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

</tbody>

</table>

``` r
# Check exact text lines that differ between Run 1 and Run 2
diff_lines <- setdiff(parsed_m[[1]]$text, parsed_m[[2]]$text)
cat("--- TEXT DIFFERENCES (RUN 1 vs RUN 2) ---\n")
```

    ## --- TEXT DIFFERENCES (RUN 1 vs RUN 2) ---

``` r
print(diff_lines)
```

    ## [1] "28 October 2026"

``` r
# Check exact text lines that differ between Run 2 and Run 3
diff_lines <- setdiff(parsed_m[[2]]$text, parsed_m[[3]]$text)
cat("--- TEXT DIFFERENCES (RUN 2 vs RUN 3) ---\n")
```

    ## --- TEXT DIFFERENCES (RUN 2 vs RUN 3) ---

``` r
print(diff_lines)
```

    ## character(0)

PASS and FAIL files check

``` r
# 1. Define file targets for Dataset M across all 3 runs (splitting PASS into entries and rows)
m_file_targets <- list(
  list(name = "PASS (Entries)", f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run1_2026.10.28/tables/madcap_FINAL_PASS_entries_entries.tsv", f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run2_2026.10.29/tables/madcap_FINAL_PASS_entries_entries.tsv", f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run3_2026.10.29/tables/madcap_FINAL_PASS_entries_entries.tsv"),
  list(name = "PASS (Rows)",    f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run1_2026.10.28/tables/madcap_FINAL_PASS_rows.tsv",    f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run2_2026.10.29/tables/madcap_FINAL_PASS_rows.tsv",    f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run3_2026.10.29/tables/madcap_FINAL_PASS_rows.tsv"),
  list(name = "FAIL_F01",       f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run1_2026.10.28/tables/madcap_F01_FAIL_rows.tsv",          f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run2_2026.10.29/tables/madcap_F01_FAIL_rows.tsv",          f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run3_2026.10.29/tables/madcap_F01_FAIL_rows.tsv"),
  list(name = "FAIL_F02",       f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run1_2026.10.28/tables/madcap_F02_FAIL_rows.tsv",          f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run2_2026.10.29/tables/madcap_F02_FAIL_rows.tsv",          f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run3_2026.10.29/tables/madcap_F02_FAIL_rows.tsv"),
  list(name = "FAIL_F03",       f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run1_2026.10.28/tables/madcap_F03_FAIL_rows.tsv",          f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run2_2026.10.29/tables/madcap_F03_FAIL_rows.tsv",          f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run3_2026.10.29/tables/madcap_F03_FAIL_rows.tsv"),
  list(name = "FAIL_F04",       f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run1_2026.10.28/tables/madcap_F04_FAIL_rows.tsv",          f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run2_2026.10.29/tables/madcap_F04_FAIL_rows.tsv",          f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run3_2026.10.29/tables/madcap_F04_FAIL_rows.tsv"),
  list(name = "FAIL_F05",       f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run1_2026.10.28/tables/madcap_F05_FAIL_rows.tsv",          f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run2_2026.10.29/tables/madcap_F05_FAIL_rows.tsv",          f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run3_2026.10.29/tables/madcap_F05_FAIL_rows.tsv"),
  list(name = "FAIL_F06",       f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run1_2026.10.28/tables/madcap_F06_FAIL_rows.tsv",          f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run2_2026.10.29/tables/madcap_F06_FAIL_rows.tsv",          f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run3_2026.10.29/tables/madcap_F06_FAIL_rows.tsv"),
  list(name = "FAIL_F07",       f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run1_2026.10.28/tables/madcap_F07_FAIL_rows.tsv",          f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run2_2026.10.29/tables/madcap_F07_FAIL_rows.tsv",          f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run3_2026.10.29/tables/madcap_F07_FAIL_rows.tsv"),
  list(name = "FAIL_F08",       f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run1_2026.10.28/tables/madcap_F08_FAIL_rows.tsv",          f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run2_2026.10.29/tables/madcap_F08_FAIL_rows.tsv",          f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run3_2026.10.29/tables/madcap_F08_FAIL_rows.tsv"),
  list(name = "FAIL_F09",       f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run1_2026.10.28/tables/madcap_F09_FAIL_rows.tsv",          f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run2_2026.10.29/tables/madcap_F09_FAIL_rows.tsv",          f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_madcap_outdir_run3_2026.10.29/tables/madcap_F09_FAIL_rows.tsv")
)

# 2. Iterative low-memory file audit function with full cell-by-cell deep comparison
audit_tsv_triplet <- function(filter_name, path1, path2, path3) {
  
  cat(sprintf("Auditing Dataset M: %s...\n", filter_name))
  
  # Load data.table objects sequentially
  dt1 <- fread(path1)
  dt2 <- fread(path2)
  dt3 <- fread(path3)
  
  r1 <- nrow(dt1); r2 <- nrow(dt2); r3 <- nrow(dt3)
  rows_match <- (r1 == r2) && (r2 == r3)
  
  # Deep cell-by-cell content check across all 3 runs
  content_match <- FALSE
  if (rows_match) {
    content_match <- identical(dt1, dt2) && identical(dt2, dt3)
  }
  
  # Immediate memory offload
  rm(dt1, dt2, dt3)
  gc(verbose = FALSE)
  
  tibble(
    File_Step = filter_name,
    Run1_Rows = r1,
    Run2_Rows = r2,
    Run3_Rows = r3,
    Row_Counts_Match = rows_match,
    Cell_Content_Identical = content_match
  )
}

# 3. Execute audit loop across Dataset M targets
dataset_m_tsv_audit <- map_dfr(m_file_targets, function(target) {
  audit_tsv_triplet(target$name, target$f1, target$f2, target$f3)
})
```

    ## Auditing Dataset M: PASS (Entries)...
    ## Auditing Dataset M: PASS (Rows)...
    ## Auditing Dataset M: FAIL_F01...
    ## Auditing Dataset M: FAIL_F02...
    ## Auditing Dataset M: FAIL_F03...
    ## Auditing Dataset M: FAIL_F04...
    ## Auditing Dataset M: FAIL_F05...
    ## Auditing Dataset M: FAIL_F06...
    ## Auditing Dataset M: FAIL_F07...
    ## Auditing Dataset M: FAIL_F08...
    ## Auditing Dataset M: FAIL_F09...

``` r
# 4. Display Summary Table
knitr::kable(
  dataset_m_tsv_audit,
  col.names = c("File / Filter Step", "Run 1 Rows", "Run 2 Rows", "Run 3 Rows", "Row Counts Match?", "Cell Content Identical?"),
  caption = "Dataset M: 3x Run TSV File Reproducibility Audit"
) %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"))
```

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<caption>

Dataset M: 3x Run TSV File Reproducibility Audit
</caption>

<thead>

<tr>

<th style="text-align:left;">

File / Filter Step
</th>

<th style="text-align:right;">

Run 1 Rows
</th>

<th style="text-align:right;">

Run 2 Rows
</th>

<th style="text-align:right;">

Run 3 Rows
</th>

<th style="text-align:left;">

Row Counts Match?
</th>

<th style="text-align:left;">

Cell Content Identical?
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

PASS (Entries)
</td>

<td style="text-align:right;">

631708
</td>

<td style="text-align:right;">

631708
</td>

<td style="text-align:right;">

631708
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

PASS (Rows)
</td>

<td style="text-align:right;">

156517
</td>

<td style="text-align:right;">

156517
</td>

<td style="text-align:right;">

156517
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

FAIL_F01
</td>

<td style="text-align:right;">

98144
</td>

<td style="text-align:right;">

98144
</td>

<td style="text-align:right;">

98144
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

FAIL_F02
</td>

<td style="text-align:right;">

290676
</td>

<td style="text-align:right;">

290676
</td>

<td style="text-align:right;">

290676
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

FAIL_F03
</td>

<td style="text-align:right;">

14414
</td>

<td style="text-align:right;">

14414
</td>

<td style="text-align:right;">

14414
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

FAIL_F04
</td>

<td style="text-align:right;">

58659
</td>

<td style="text-align:right;">

58659
</td>

<td style="text-align:right;">

58659
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

FAIL_F05
</td>

<td style="text-align:right;">

217088
</td>

<td style="text-align:right;">

217088
</td>

<td style="text-align:right;">

217088
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

FAIL_F06
</td>

<td style="text-align:right;">

213039
</td>

<td style="text-align:right;">

213039
</td>

<td style="text-align:right;">

213039
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

FAIL_F07
</td>

<td style="text-align:right;">

16117
</td>

<td style="text-align:right;">

16117
</td>

<td style="text-align:right;">

16117
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

FAIL_F08
</td>

<td style="text-align:right;">

0
</td>

<td style="text-align:right;">

0
</td>

<td style="text-align:right;">

0
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

FAIL_F09
</td>

<td style="text-align:right;">

0
</td>

<td style="text-align:right;">

0
</td>

<td style="text-align:right;">

0
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

</tbody>

</table>

``` r
# 1. Remove large Dataset M objects from environment
rm(list = ls(pattern = "^parsed_m|^dataset_m|^m_file_targets"))

# 2. Trigger explicit garbage collection to free RAM
gc(verbose = TRUE)
```

    ##           used (Mb) gc trigger  (Mb)  max used   (Mb)
    ## Ncells 1352803 72.3    4364488 233.1   2665568  142.4
    ## Vcells 3336025 25.5   75188845 573.7 266687785 2034.7

``` r
cat("Workspace memory cleared and garbage collection complete. Ready for Dataset D.\n")
```

    ## Workspace memory cleared and garbage collection complete. Ready for Dataset D.

------------------------------------------------------------------------

## DDD-Africa Analysis

Report checks

``` r
# 1. Define file paths for Dataset D HTML reports across 3 runs
report_paths_d <- c(
  "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run2_2026.10.29/report/main.html",
  "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run3_2026.10.29/report/main.html",
  "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run4_2026.10.29/report/main.html"
)

# 2. Extract and sanitize HTML report content
parse_and_clean_report <- function(path) {
  page <- read_html(path)
  
  # Extract body text and strip dynamic execution metadata (timestamps, runtimes, file paths)
  raw_text <- page %>% 
    html_nodes("p, h1, h2, h3, h4, li") %>% 
    html_text(trim = TRUE)
  
  clean_text <- raw_text %>%
    grep("^$", ., invert = TRUE, value = TRUE) %>%
    gsub("\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}", "[TIMESTAMP]", .) %>%
    gsub("\\d+(\\.\\d+)?\\s*(sec|min|hours|s|m|seconds|minutes)", "[DURATION]", .) %>%
    gsub("/[A-Za-z0-9_.-]+/", "[PATH]/", .)
  
  # Extract structural data tables
  tables <- page %>% 
    html_nodes("table") %>% 
    html_table()
  
  list(text = clean_text, tables = tables)
}

# 3. Parse all 3 Dataset D reports
parsed_d <- lapply(report_paths_d, parse_and_clean_report)

# 4. Generate content checksums and compare against Run 1
text_hashes_d  <- sapply(parsed_d, function(x) digest(x$text, algo = "md5"))
table_hashes_d <- sapply(parsed_d, function(x) digest(x$tables, algo = "md5"))

report_audit_d <- tibble(
  Run = paste("Run", 1:3),
  Text_MD5 = text_hashes_d,
  Table_MD5 = table_hashes_d,
  Text_Match_Run1 = text_hashes_d == text_hashes_d[1],
  Tables_Match_Run1 = table_hashes_d == table_hashes_d[1]
)

# 5. Display comparison summary
cat("--- DATASET D: HTML REPORT REPRODUCIBILITY AUDIT ---\n\n")
```

    ## --- DATASET D: HTML REPORT REPRODUCIBILITY AUDIT ---

``` r
knitr::kable(
  report_audit_d,
  col.names = c("Run", "Text Hash (MD5)", "Table Hash (MD5)", "Text Identical (vs Run 1)", "Tables Identical (vs Run 1)"),
  caption = "Dataset D: 3x Run HTML Report Content Equivalence"
) %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"))
```

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<caption>

Dataset D: 3x Run HTML Report Content Equivalence
</caption>

<thead>

<tr>

<th style="text-align:left;">

Run
</th>

<th style="text-align:left;">

Text Hash (MD5)
</th>

<th style="text-align:left;">

Table Hash (MD5)
</th>

<th style="text-align:left;">

Text Identical (vs Run 1)
</th>

<th style="text-align:left;">

Tables Identical (vs Run 1)
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Run 1
</td>

<td style="text-align:left;">

80a96c736b61f4e3074f85a9978587ee
</td>

<td style="text-align:left;">

f6d3df7800d1a5f0f67937ddc666cf74
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

Run 2
</td>

<td style="text-align:left;">

80a96c736b61f4e3074f85a9978587ee
</td>

<td style="text-align:left;">

f6d3df7800d1a5f0f67937ddc666cf74
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

Run 3
</td>

<td style="text-align:left;">

4a5e428b1d9bb9a7570f2d7adda0ee85
</td>

<td style="text-align:left;">

f6d3df7800d1a5f0f67937ddc666cf74
</td>

<td style="text-align:left;">

FALSE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

</tbody>

</table>

``` r
# Check exact text lines that differ between Run 1 and Run 2
diff_lines <- setdiff(parsed_d[[1]]$text, parsed_d[[2]]$text)
cat("--- TEXT DIFFERENCES (RUN 1 vs RUN 2) ---\n")
```

    ## --- TEXT DIFFERENCES (RUN 1 vs RUN 2) ---

``` r
print(diff_lines)
```

    ## character(0)

``` r
# Check exact text lines that differ between Run 2 and Run 3
diff_lines <- setdiff(parsed_d[[2]]$text, parsed_d[[3]]$text)
cat("--- TEXT DIFFERENCES (RUN 2 vs RUN 3) ---\n")
```

    ## --- TEXT DIFFERENCES (RUN 2 vs RUN 3) ---

``` r
print(diff_lines)
```

    ## [1] "29 October 2026"

PASS and FAIL files check

``` r
# 1. Define file targets for Dataset D across all 3 runs (splitting PASS into entries and rows)
d_file_targets <- list(
  list(name = "PASS (Entries)", f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run2_2026.10.29/tables/ddd-africa_FINAL_PASS_entries_entries.tsv", f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run3_2026.10.29/tables/ddd-africa_FINAL_PASS_entries_entries.tsv", f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run4_2026.10.29/tables/ddd-africa_FINAL_PASS_entries_entries.tsv"),
  list(name = "PASS (Rows)",    f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run2_2026.10.29/tables/ddd-africa_FINAL_PASS_rows.tsv",    f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run3_2026.10.29/tables/ddd-africa_FINAL_PASS_rows.tsv",    f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run4_2026.10.29/tables/ddd-africa_FINAL_PASS_rows.tsv"),
  list(name = "FAIL_F01",       f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run2_2026.10.29/tables/ddd-africa_F01_FAIL_rows.tsv",          f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run3_2026.10.29/tables/ddd-africa_F01_FAIL_rows.tsv",          f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run4_2026.10.29/tables/ddd-africa_F01_FAIL_rows.tsv"),
  list(name = "FAIL_F03",       f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run2_2026.10.29/tables/ddd-africa_F03_FAIL_rows.tsv",          f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run3_2026.10.29/tables/ddd-africa_F03_FAIL_rows.tsv",          f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run4_2026.10.29/tables/ddd-africa_F03_FAIL_rows.tsv"),
  list(name = "FAIL_F04",       f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run2_2026.10.29/tables/ddd-africa_F04_FAIL_rows.tsv",          f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run3_2026.10.29/tables/ddd-africa_F04_FAIL_rows.tsv",          f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run4_2026.10.29/tables/ddd-africa_F04_FAIL_rows.tsv"),
  list(name = "FAIL_F05",       f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run2_2026.10.29/tables/ddd-africa_F05_FAIL_rows.tsv",          f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run3_2026.10.29/tables/ddd-africa_F05_FAIL_rows.tsv",          f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run4_2026.10.29/tables/ddd-africa_F05_FAIL_rows.tsv"),
  list(name = "FAIL_F06",       f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run2_2026.10.29/tables/ddd-africa_F06_FAIL_rows.tsv",          f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run3_2026.10.29/tables/ddd-africa_F06_FAIL_rows.tsv",          f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run4_2026.10.29/tables/ddd-africa_F06_FAIL_rows.tsv"),
  list(name = "FAIL_F07",       f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run2_2026.10.29/tables/ddd-africa_F07_FAIL_rows.tsv",          f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run3_2026.10.29/tables/ddd-africa_F07_FAIL_rows.tsv",          f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run4_2026.10.29/tables/ddd-africa_F07_FAIL_rows.tsv"),
  list(name = "FAIL_F08",       f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run2_2026.10.29/tables/ddd-africa_F08_FAIL_rows.tsv",          f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run3_2026.10.29/tables/ddd-africa_F08_FAIL_rows.tsv",          f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run4_2026.10.29/tables/ddd-africa_F08_FAIL_rows.tsv"),
  list(name = "FAIL_F09",       f1 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run2_2026.10.29/tables/ddd-africa_F09_FAIL_rows.tsv",          f2 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run3_2026.10.29/tables/ddd-africa_F09_FAIL_rows.tsv",          f3 = "C:/Users/Chrizelle/Documents/Research_Report/Analysis/var_filt_ddd-africa_outdir_run4_2026.10.29/tables/ddd-africa_F09_FAIL_rows.tsv")
)

# 2. Iterative low-memory file audit function with full cell-by-cell deep comparison
audit_tsv_triplet <- function(filter_name, path1, path2, path3) {
  
  cat(sprintf("Auditing Dataset D: %s...\n", filter_name))
  
  # Load data.table objects sequentially
  dt1 <- fread(path1)
  dt2 <- fread(path2)
  dt3 <- fread(path3)
  
  r1 <- nrow(dt1); r2 <- nrow(dt2); r3 <- nrow(dt3)
  rows_match <- (r1 == r2) && (r2 == r3)
  
  # Deep cell-by-cell content check across all 3 runs
  content_match <- FALSE
  if (rows_match) {
    content_match <- identical(dt1, dt2) && identical(dt2, dt3)
  }
  
  # Immediate memory offload
  rm(dt1, dt2, dt3)
  gc(verbose = FALSE)
  
  tibble(
    File_Step = filter_name,
    Run1_Rows = r1,
    Run2_Rows = r2,
    Run3_Rows = r3,
    Row_Counts_Match = rows_match,
    Cell_Content_Identical = content_match
  )
}

# 3. Execute audit loop across Dataset D targets
dataset_d_tsv_audit <- map_dfr(d_file_targets, function(target) {
  audit_tsv_triplet(target$name, target$f1, target$f2, target$f3)
})
```

    ## Auditing Dataset D: PASS (Entries)...
    ## Auditing Dataset D: PASS (Rows)...
    ## Auditing Dataset D: FAIL_F01...
    ## Auditing Dataset D: FAIL_F03...
    ## Auditing Dataset D: FAIL_F04...
    ## Auditing Dataset D: FAIL_F05...
    ## Auditing Dataset D: FAIL_F06...
    ## Auditing Dataset D: FAIL_F07...
    ## Auditing Dataset D: FAIL_F08...
    ## Auditing Dataset D: FAIL_F09...

``` r
# 4. Display Summary Table
knitr::kable(
  dataset_d_tsv_audit,
  col.names = c("File / Filter Step", "Run 1 Rows", "Run 2 Rows", "Run 3 Rows", "Row Counts Match?", "Cell Content Identical?"),
  caption = "Dataset D: 3x Run TSV File Reproducibility Audit"
) %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"))
```

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<caption>

Dataset D: 3x Run TSV File Reproducibility Audit
</caption>

<thead>

<tr>

<th style="text-align:left;">

File / Filter Step
</th>

<th style="text-align:right;">

Run 1 Rows
</th>

<th style="text-align:right;">

Run 2 Rows
</th>

<th style="text-align:right;">

Run 3 Rows
</th>

<th style="text-align:left;">

Row Counts Match?
</th>

<th style="text-align:left;">

Cell Content Identical?
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

PASS (Entries)
</td>

<td style="text-align:right;">

3728342
</td>

<td style="text-align:right;">

3728342
</td>

<td style="text-align:right;">

3728342
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

PASS (Rows)
</td>

<td style="text-align:right;">

359143
</td>

<td style="text-align:right;">

359143
</td>

<td style="text-align:right;">

359143
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

FAIL_F01
</td>

<td style="text-align:right;">

179662
</td>

<td style="text-align:right;">

179662
</td>

<td style="text-align:right;">

179662
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

FAIL_F03
</td>

<td style="text-align:right;">

14920
</td>

<td style="text-align:right;">

14920
</td>

<td style="text-align:right;">

14920
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

FAIL_F04
</td>

<td style="text-align:right;">

55579
</td>

<td style="text-align:right;">

55579
</td>

<td style="text-align:right;">

55579
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

FAIL_F05
</td>

<td style="text-align:right;">

469557
</td>

<td style="text-align:right;">

469557
</td>

<td style="text-align:right;">

469557
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

FAIL_F06
</td>

<td style="text-align:right;">

466943
</td>

<td style="text-align:right;">

466943
</td>

<td style="text-align:right;">

466943
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

FAIL_F07
</td>

<td style="text-align:right;">

34102
</td>

<td style="text-align:right;">

34102
</td>

<td style="text-align:right;">

34102
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

FAIL_F08
</td>

<td style="text-align:right;">

0
</td>

<td style="text-align:right;">

0
</td>

<td style="text-align:right;">

0
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

<tr>

<td style="text-align:left;">

FAIL_F09
</td>

<td style="text-align:right;">

0
</td>

<td style="text-align:right;">

0
</td>

<td style="text-align:right;">

0
</td>

<td style="text-align:left;">

TRUE
</td>

<td style="text-align:left;">

TRUE
</td>

</tr>

</tbody>

</table>
