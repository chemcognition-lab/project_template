# project_template

<a target="_blank" href="https://cookiecutter-data-science.drivendata.org/">
    <img src="https://img.shields.io/badge/CCDS-Project%20template-328F97?logo=cookiecutter" />
</a>

This is an opinionated template based on the **[Cookiecutter Data Science (v2)](https://cookiecutter-data-science.drivendata.org/)** framework. We use it to keep our research clean, structured, and reproducible.

## Quick Start (Environment Setup)

We use **mamba** to manage environments. While tools like `uv` are awesome and extremely fast for pure Python, conda/mamba is still needed when dealing with non-pip installable packages (like C++ libs, CUDA, etc.). In the future, a tool like `pixi` might replace this.

1. **Clone the repository** and navigate to it.
2. **Run the setup script** to configure your project:
   ```bash
   ./setup_project.sh <new_project_name>
   ```
   This script will rename the template package to your project name, create a mamba virtual environment, register a custom Jupyter kernel, and install your package in editable mode as a local library.

Read the final lines of the setup script output to see the exact commands needed to activate and use your environment.

To only rename the package without creating the mamba environment, run:
```bash
./setup_project.sh <new_project_name> --no-setup
```

## Tooling Recommendations

A few suggestions to make life easier:

- **[VSCode](https://code.visualstudio.com/)**: Good choice for an editor.
  - *Recommended Extensions*: [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python), [Pylance](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance), [Ruff](https://marketplace.visualstudio.com/items?itemName=charliermarsh.ruff), and [Jupyter](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter).
- **[micromamba](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html)**: Environment manager to keep packages isolated so nothing breaks.
- **[Ruff](https://astral.sh/ruff)**: Extremely fast linter/formatter. Saves time arguing about formats.
- **[Pyrefly](https://github.com/facebook/pyrefly)**: Checks type safety so you catch bugs before code runs.
- **[draccus](https://github.com/dakinghara/draccus)**: Config parser for hyperparameters using typed Python structures.
- **[loguru](https://github.com/delgan/loguru)**: Easy logging without boilerplate.

## Coding Style & AI Usage

We follow the **[Google Python Style Guide](https://google.github.io/styleguide/pyguide.html)** to keep things readable.

**A note on AI usage:**
AI tools are super helpful, especially for churning out boilerplate code. But be careful, especially with scientific work. Going too fast makes it easy to pile up debt—technical debt, cognitive debt, and a lack of deep understanding of your own codebase. Debt isn't necessarily bad, but you have to pay it back eventually, and it usually comes with interest. Keep this paper in mind: **[Hidden Technical Debt in Machine Learning Systems](https://proceedings.neurips.cc/paper_files/paper/2015/file/86df7dcfd896fcaf2674f757a2463eba-Paper.pdf)**.

## Code Philosophy

- **Scripts vs. Notebooks vs. Library**: Notebooks are for messing around and exploration. Scripts are for pipelines and tasks you run once. Put reusable stuff in the [project_template](project_template) folder as library code.
- **Keep Code Small**: Try to keep files and functions under 50-100 lines. Use helper functions. If you find yourself copying code to multiple places, move it into the library.
- **Migration Workflow**: Start prototyping in a notebook to iterate quickly, then clean it up and migrate it into scripts or library code. Notebooks are good for exploring/learning, not for production or final results.
- **Simple Data Structures**: Use `dataclasses` or `pydantic` for basic data structures.
- **Composition Over Inheritance**: Favor [composition over inheritance](https://python-patterns.guide/gang-of-four/composition-over-inheritance/). It makes code cleaner and easier to reason about.
- **Libraries Over Frameworks**: Favor [libraries over frameworks](https://web.archive.org/web/20200606030038/https://www.brandonsmith.ninja/blog/libraries-not-frameworks) to stay in control of the flow and simplify dependencies.

## Saving Models

When saving models, do it so you (or someone else) can actually run them later:
- **Weights**: Use [safetensors](https://github.com/huggingface/safetensors) for fast and secure serialization (much safer than pickle).
- **Hyperparameters**: Save configurations as JSON or YAML using draccus.
- **Baseline Stats**: Store a quick eval summary next to the weights. You want to be 100% sure the model you loaded is actually the one you think it is.

## Managing Results

To keep figures and logs organized:
- **Separate Folders**: Make a new folder under `results` for each experiment or research idea.
- **Figures**: Save plots as BOTH PNG and SVG (so you can edit vector paths later).
- **Predictions & Tables**: Use CSVs for small files or serialized predictions. You want to be able to re-calculate or re-plot them easily.

## Project Structure

```
├── LICENSE            <- Legal terms for code usage and distribution.
├── README.md          <- Setup instructions and project overview.
├── pyproject.toml     <- Configuration for Python packaging and tools (Ruff, Pyrefly).
├── environment.yml    <- Environment recipe listing packages and dependencies.
├── setup.sh           <- Script to create mamba environment, install package, and register kernel.
├── setup_project.sh   <- Script to rename the project and trigger setup.sh.
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
