# Workflow Evaluation, Performance Profiling & Validation Scripts

This directory contains a Python utility script and R analysis scripts for evaluating execution computational performance, verifying variant filtering accuracy, assessing reproducibility and scalability, and analyzing user feedback for the variant filtering workflow.

For R Markdown (`.Rmd`) analyses, both the source `.Rmd` files and knitted GitHub-Flavored Markdown (`.md`) reports (with embedded figures) are provided so that code, statistical outputs, and visualizations can be inspected directly in the browser.

## 🛠️ Python Performance Profiling

### 1. `metrics.py` (Jupyter Performance Profiling)
* **Language:** Python (`psutil`, `pandas`, `IPython`)
* **Purpose:** Uses IPython event hooks (`pre_run_cell` / `post_run_cell`) to monitor per-cell wall-clock runtime, CPU core utilization (benchmarked against a 40-core allocation), and RAM usage (RSS in MB).
* **Usage:** Copy the initial setup hook into an early cell of your Jupyter Notebook, and run the summary block in the final cell.
* **Outputs:**
  * `per_step_execution_report.csv` — Granular cell-by-cell runtime and resource consumption.
  * `total_workflow_summary.csv` — Aggregated runtime, peak core usage, and peak RAM consumption.

## 📊 R Validation, Benchmarking & Survey Scripts

### 2. `var_filt_analysis.Rmd` / `.md` (Variant Filtering Audit)
* **Scope:** Evaluated across **both** test datasets.
* **Purpose:** Audits the filtering logic across workflow steps to confirm that variants strictly meet filtering criteria to be retained or removed.

### 3. `known_p_var_check_ddd-africa.Rmd` / `.md` (Capture of Known Pathogenic Variation)
* **Scope:** Evaluated on **one** of the test datasets.
* **Purpose:** Assesses the workflow's ability to capture known pathogenic variants, calculating key classification metrics including **accuracy**, **precision**, **false positive rate (capture rate / FPR)**, and **false negative rate (FNR)**.

### 4. `reproducibility_checks.Rmd` / `.md` (Computational Reproducibility Verification)
* **Scope:** Evaluated across **both** test datasets.
* **Purpose:** Verifies computational reproducibility by confirming that identical variant filtering outputs are generated across independent runs when using the exact same input data, parameters, and containerized environment.

### 5. `scalability_check.Rmd` / `.md` (Workflow Scalability Evaluation)
* **Scope:** Evaluated across **both** test datasets.
* **Purpose:** Evaluates the pipeline's ability to handle increasing genomic data volumes efficiently without failures.

### 6. `survey_responses.R` (User Feedback Survey Visualization)
* **Language:** R
* **Purpose:** Processes and plots user feedback survey responses regarding the variant filtering report, directly informing the design of additional interactive visualizations in the main repository.


## 👤 AI Disclosure
**Google Gemini** was utilized to assist in writing and refining portions of the Python profiling logic in `metrics.py` and structuring R analysis scripts. All code, statistical calculations, and knitted outputs were independently executed and validated by the author.