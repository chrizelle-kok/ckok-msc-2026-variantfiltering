# ckok-msc-2026-variantfiltering

This repository contains Python scripts to generate independent visualizations in the form of interactive `.html` plot outputs for evaluating human germline Next Generation Sequencing (NGS) data in variant filtering workflows, as well as a standalone workflow evaluation script to monitor workflow performance.

The visualization scripts extract and process variant data loaded into a [Hail](https://hail.is/) MatrixTable (converting relevant metrics into [pandas](https://pandas.pydata.org/) DataFrames for downstream processing) and output standalone, interactive figures generated with [Plotly](https://plotly.com/python/) and [Bokeh](https://docs.bokeh.org/). Complementing these visual outputs, the repository includes an `analysis/` directory containing a resource profiling script for performance tracking across the variant filtering workflow (executed in Jupyter Notebook).


## 📁 Repository Structure

```text
variant-filtering-visuals/
├── synthetic_exomes.mt/     # Pre-generated Hail MatrixTable test input (from syntetic exomes)
├── data/
│   └── my_dataset.mt/       # hail MatrixTable folder containing sample QC metrics
├── analysis/                # Workflow evaluation & validation scripts
│   ├── metrics.py           # Jupyter cell profiling & resource usage capture
│   └── README.md            # Documentation for analysis script
├── generate_pca.py          # Visualization script (PCA)
├── generate_titv_plot.py    # Visualization script (Ti/Tv)
├── generate_sunburst.py     # Visualization script (Sunburst)
├── pca_3d_report.html       # Figure output
├── titv_qc_report.html      # Figure output
├── filtering_sunburst.html  # Figure output
└── README.md                # Project documentation
```

## 🛠️ Environment & Prerequisites

### Execution Environment (Container)

The Jupyter Notebook integrating these scripts is executed within a pre-configured Apptainer container containing all required dependencies (`Hail`, `pandas`, `Bokeh`, `Plotly`, `psutil`, and more).

- Container Image URL: [Docker Hail](https://hub.docker.com/repository/docker/phelelani/nf-bioinftools/tags/hail_v0.2.139/)

## 🚀 Workflow Execution

### 1. Generating Visulaizations

Each script runs independently and processes the included synthetic_exomes.mt MatrixTable. Where applicable, metrics are exported from Hail into pandas DataFrames to streamline data manipulation prior to rendering.

To execute or re-generate any visualization, run the respective script:

```bash
# Run PCA analysis
python generate_pca.py

# Run Transistion/Transversion analysis
python generate_titv_plot.py

# Run variant retained/removed counts
python generate_sunburst.py
```
Each script outputs or overwrites its corresponding `.html` file. Open any generated `.html` file in your browser to inspect the interactive figure.

### 2. Running Performance Profiling

To capture total and per-cell execution runtime, peak RAM, and CPU core utilization during Jupyter Notebook execution, refer to the setup instructions provided in `analysis/README.md` to embed metrics.py into notebook workflow.

## 👤 Author & Acknowledgments
* **Contributor:** Chrizelle Kok (@chrizelle-kok)

* **Project Role:** Designed visualization scripts for variant filtering outputs for integration into the Quarto reporting framework. Developed workflow profiling tools.

* **Main Workflow Repository:** Developed under the supervision of [@phelelani](https://github.com/phelelani). This project complements the main variant filtering workflow hosted at [nf-variantfilt](https://github.com/phelelani/nf-variantfilt).
* **Disclaimer:**  **Google Gemini** was utilized to assist in writing and refining portions of the Python code for data processing and HTML visualization generation. All generated code was independently executed, tested, and validated by the author.