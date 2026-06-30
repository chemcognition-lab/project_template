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

echo "Setting up mamba environment '$ENV_NAME'..."
mamba env create -f environment.yml

echo "Installing package in editable mode..."
mamba run -n "$ENV_NAME" pip install -e .

echo "Registering Jupyter kernel..."
mamba run -n "$ENV_NAME" python -m ipykernel install --user --name "$ENV_NAME" --display-name "Python ($ENV_NAME)"

echo "Setup complete! Activate with: mamba activate $ENV_NAME"
