# project_template

## Setup

To set up the environment and install the package for development:
```bash
./setup.sh
```

This creates the micromamba environment, installs the package in editable mode, and registers the Jupyter kernel.

For HPC cluster deployment ($SCRATCH):
```bash
./hpc/setup_env.sh
source hpc/activate_env.sh
```

## Project Structure

```
├── LICENSE            <- Legal terms for code usage and distribution.
├── README.md          <- Setup instructions and project overview.
├── pyproject.toml     <- Configuration for Python packaging and tools (Ruff, Pyrefly).
├── environment.yml    <- Environment recipe listing packages and dependencies.
├── setup.sh           <- Script to create micromamba environment, install package, and register kernel.
├── hpc
│   ├── setup_env.sh   <- Script to initialize micromamba environment on HPC clusters ($SCRATCH).
│   └── activate_env.sh<- Helper script to load modules and activate cluster environment.
├── data
│   ├── interim        <- Intermediate transformed or cleaned datasets.
│   ├── processed      <- Final datasets ready for modeling.
│   └── raw            <- Immutable source data.
│
├── models             <- Trained models and parameters.
│   └── ModelA         <- Model A weights and artifacts.
│
├── notebooks          <- Jupyter notebooks for exploration and prototyping.
├── scripts            <- Executable workflows and pipelines.
│
├── results            <- Generated analysis output (reports, logs).
│   └── figures        <- Visual graphics and plots.
│
└── project_template   <- Reusable source code.
    ├── __init__.py    <- Package initializer.
    ├── paths_and_constants.py <- Centralized paths and configuration constants.
    ├── utils.py       <- Reusable helper utilities.
    └── vis.py         <- Visualization style settings and helpers.
```
