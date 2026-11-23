# Workflow Evaluation & Validation Scripts

This directory contains the utility script for evaluating execution performance throughout the variant filtering workflow.


## 🛠️ Script

### 1. `metrics.py` (Jupyter Performance Profiling)
* **Language:** Python (`psutil`, `pandas`, `IPython`)
* **Purpose:** Uses IPython event hooks (`pre_run_cell` / `post_run_cell`) to monitor per-cell wall-clock runtime, CPU core utilization (benchmarked against a 40-core allocation), and RAM usage (RSS in MB).
* **Usage:** Copy the initial setup hook into an early cell of your Jupyter Notebook, and run the summary block in the final cell.
* **Outputs:**
  * `per_step_execution_report.csv` — Granular cell-by-cell runtime and resource consumption.
  * `total_workflow_summary.csv` — Aggregated runtime, peak core usage, and peak RAM consumption.


## 👤 AI Disclosure
**Google Gemini** was utilized to assist in writing and refining portions of the Python profiling logic in `metrics.py`. All metrics logic and resulting CSV outputs were independently executed and validated by the author.