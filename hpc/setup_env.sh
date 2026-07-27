#!/bin/bash
# HPC Environment Setup Script using Standalone Micromamba
# Run this on a login node (which has internet access) to set up the environment.

set -e

# Automatically resolve the repository root (parent folder of this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "=== Switched to repository root: $(pwd) ==="

BIN_DIR="$HOME/.local/bin"
MICROMAMBA_EXE="$BIN_DIR/micromamba"

# Setup SCRATCH fallback for local/testing environments
IS_LOCAL=0
if [ -z "$SCRATCH" ]; then
    echo "=== WARNING: \$SCRATCH is not defined. Assuming local machine environment ==="
    SCRATCH="$HOME/scratch"
    IS_LOCAL=1
fi
mkdir -p "$SCRATCH"

ENV_NAME=$(grep -m 1 "^name:" environment.yml | sed 's/name:[[:space:]]*//')
if [ -z "$ENV_NAME" ]; then
    ENV_NAME="project_template"
fi

SCRATCH_MAMBA_DIR="$SCRATCH/micromamba_cache"
SCRATCH_ENV_DIR="$SCRATCH/envs/$ENV_NAME"

# 1. Download micromamba if not already present
if [ ! -f "$MICROMAMBA_EXE" ]; then
    echo "=== Downloading standalone Micromamba static binary ==="
    mkdir -p "$BIN_DIR"
    curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xj -C "$BIN_DIR" --strip-components=1 bin/micromamba
    chmod +x "$MICROMAMBA_EXE"
fi

echo "=== Configuring Micromamba Caches ==="
mkdir -p "$SCRATCH_MAMBA_DIR"
# Configure micromamba to use scratch for package downloads to save home folder quotas
"$MICROMAMBA_EXE" config append pkgs_dirs "$SCRATCH_MAMBA_DIR"
"$MICROMAMBA_EXE" config append envs_dirs "$SCRATCH/envs"
"$MICROMAMBA_EXE" config set channel_priority strict

# Initialize micromamba shell hook
eval "$("$MICROMAMBA_EXE" shell hook --shell=bash)"

if [ -d "$SCRATCH_ENV_DIR" ]; then
    echo "=== Updating existing Environment from environment.yml ==="
    "$MICROMAMBA_EXE" env update --prefix "$SCRATCH_ENV_DIR" -f environment.yml --prune -y
else
    echo "=== Creating Environment from environment.yml ==="
    "$MICROMAMBA_EXE" env create --prefix "$SCRATCH_ENV_DIR" -f environment.yml -y
fi

echo "=== Activating Environment ==="
micromamba activate "$SCRATCH_ENV_DIR"

echo "=== Installing the local project '$ENV_NAME' in editable mode ==="
pip install -e .

echo "=== Setting up results directory ==="
REPO_NAME=$(basename "$(pwd)")
if [ "$IS_LOCAL" -eq 0 ]; then
    mkdir -p "$SCRATCH/$REPO_NAME/results/logs"
    if [ ! -L "results" ] && [ ! -d "results" ]; then
        ln -s "$SCRATCH/$REPO_NAME/results" results
    elif [ -d "results" ] && [ ! -L "results" ]; then
        mv results/* "$SCRATCH/$REPO_NAME/results/" 2>/dev/null || true
        rm -rf results
        ln -s "$SCRATCH/$REPO_NAME/results" results
    fi
else
    echo "=== Local environment: keeping results directory local ==="
    mkdir -p results/logs
fi

echo "=== Setup complete! ==="
echo "To activate this environment in future scripts or interactive sessions, run:"
echo "eval \"\$($HOME/.local/bin/micromamba shell hook --shell=bash)\" && micromamba activate $SCRATCH_ENV_DIR"
