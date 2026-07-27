#!/bin/sh

# Usage:
#   ./setup.sh

# Exit immediately if a command exits with a non-zero status
set -e

# Extract the environment name from environment.yml
ENV_NAME=$(grep -m 1 "^name:" environment.yml | sed 's/name:[[:space:]]*//')

if [ -z "$ENV_NAME" ]; then
    echo "Error: Could not find environment name in environment.yml"
    exit 1
fi

# Detect package manager (micromamba > mamba > conda > auto-install micromamba)
if command -v micromamba >/dev/null 2>&1; then
    MGR="micromamba"
    echo "Found micromamba. Using it for setup..."
elif command -v mamba >/dev/null 2>&1; then
    MGR="mamba"
    echo "Found mamba. Using it for setup..."
elif command -v conda >/dev/null 2>&1; then
    MGR="conda"
    echo "Found conda. Using it for setup..."
else
    echo "No micromamba, mamba, or conda found in PATH."
    echo "Installing micromamba automatically..."
    curl -Lsk https://micro.mamba.pm/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    if command -v micromamba >/dev/null 2>&1; then
        MGR="micromamba"
        echo "Successfully installed micromamba!"
    else
        echo "Installation succeeded, but 'micromamba' is still not found in PATH."
        echo "Please install conda, mamba, or micromamba manually, then run this script again."
        exit 1
    fi
fi

echo "Setting up environment '$ENV_NAME'..."
$MGR env create -f environment.yml -y

echo "Installing package in editable mode..."
$MGR run -n "$ENV_NAME" pip install -e .

echo "Installing pre-commit hooks..."
$MGR run -n "$ENV_NAME" pre-commit install

echo "Registering Jupyter kernel..."
$MGR run -n "$ENV_NAME" python -m ipykernel install --user --name "$ENV_NAME" --display-name "Python ($ENV_NAME)"

echo "Setup complete! Activate with: $MGR activate $ENV_NAME"

