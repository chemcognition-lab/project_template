#!/bin/bash
# Unified HPC environment activation script for SciNet/Alliance clusters
# Usage: source hpc/activate_env.sh

# 1. Resolve repository root (parent folder of hpc directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Extract environment name from environment.yml if available
ENV_NAME=$(grep -m 1 "^name:" environment.yml | sed 's/name:[[:space:]]*//')
if [ -z "$ENV_NAME" ]; then
    ENV_NAME="project_template"
fi

# 2. Setup SCRATCH fallback for local/testing environments
IS_LOCAL=0
if [ -z "$SCRATCH" ]; then
    echo "=== WARNING: \$SCRATCH is not defined. Assuming local machine environment ==="
    SCRATCH="$HOME/scratch"
    IS_LOCAL=1
fi

REPO_NAME=$(basename "$(pwd)")

# 3. Ensure results directory is on SCRATCH and symlinked (only on HPC clusters)
if [ "$IS_LOCAL" -eq 0 ]; then
    mkdir -p "$SCRATCH/$REPO_NAME/results/logs"
    if [ ! -L "results" ]; then
        if [ -d "results" ]; then
            echo "=== Moving existing results to SCRATCH and symlinking ==="
            mv results/* "$SCRATCH/$REPO_NAME/results/" 2>/dev/null || true
            rm -rf results
        fi
        ln -s "$SCRATCH/$REPO_NAME/results" results
    fi
else
    echo "=== Local environment detected. Keeping results directory local ==="
    mkdir -p results/logs
fi

# 4. Load compiler and CUDA modules depending on the cluster
if command -v module &> /dev/null; then
    # Detect Balam (SciNet local cluster) vs standard Alliance clusters (Trillium, Killarney, TamIA, Vulcan, Nibi)
    if hostname | grep -q -e "balam" -e "b-compute"; then
        echo "=== Balam Cluster Detected: Loading gcc and cuda modules ==="
        module load gcc/12.3.0 cuda
    else
        echo "=== Alliance/SciNet-Alliance Cluster Detected: Loading StdEnv, gcc, and cuda modules ==="
        module load StdEnv/2023 gcc/12.3 cuda/12.2
    fi
else
    echo "=== 'module' command not found. Skipping module load (likely local environment) ==="
fi

# 5. Activating Micromamba / Conda environment
MICROMAMBA_EXE="$HOME/.local/bin/micromamba"
if [ -f "$MICROMAMBA_EXE" ]; then
    echo "=== Activating Micromamba Environment ($SCRATCH/envs/$ENV_NAME) ==="
    eval "$("$MICROMAMBA_EXE" shell hook --shell=bash)"
    micromamba activate "$SCRATCH/envs/$ENV_NAME"
else
    echo "=== Micromamba static binary not found at $MICROMAMBA_EXE ==="
    if command -v micromamba &> /dev/null; then
        echo "=== Using system micromamba ==="
        eval "$(micromamba shell hook --shell=bash)"
        micromamba activate "$SCRATCH/envs/$ENV_NAME"
    elif command -v mamba &> /dev/null; then
        echo "=== Using system mamba ==="
        eval "$(mamba shell.bash hook)"
        mamba activate "$ENV_NAME" || mamba activate "$SCRATCH/envs/$ENV_NAME"
    elif command -v conda &> /dev/null; then
        echo "=== Using system conda ==="
        eval "$(conda shell.bash hook)"
        conda activate "$ENV_NAME" || conda activate "$SCRATCH/envs/$ENV_NAME"
    else
        echo "=== WARNING: No package manager (micromamba, mamba, or conda) detected! ==="
    fi
fi

# 6. Configure environment variables for compute nodes (where HOME/PROJECT are read-only)
export XDG_CACHE_HOME="$SCRATCH/.cache"
export XDG_CONFIG_HOME="$SCRATCH/.config"
export PYTHONUSERBASE="$SCRATCH/.local"
export TRITON_CACHE_DIR="$SCRATCH/.triton"
export MPLCONFIGDIR="$SCRATCH/.config/matplotlib"

# Configure offline logging for Weights & Biases
export WANDB_MODE=offline
export WANDB_DIR="$SCRATCH/wandb_logs"

# Force Python output to be completely unbuffered (so logs flush in real-time)
export PYTHONUNBUFFERED=1

echo "=== Environment successfully initialized! ==="
