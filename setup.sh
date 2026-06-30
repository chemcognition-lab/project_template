#!/bin/sh

# Usage:
#   ./setup.sh <new_project_name> [--no-setup]
#
# Examples:
#   ./setup.sh my_fancy_project
#   ./setup.sh my_fancy_project --no-setup

# Exit immediately if a command exits with a non-zero status
set -e

SETUP=true
NEW_NAME=""

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --no-setup|-n)
            SETUP=false
            shift
            ;;
        *)
            if [ -n "$NEW_NAME" ]; then
                echo "Error: Multiple project names specified: $NEW_NAME and $1"
                exit 1
            fi
            NEW_NAME="$1"
            shift
            ;;
    esac
done

if [ -z "$NEW_NAME" ]; then
    echo "Usage: $0 <new_project_name> [--no-setup]"
    echo "Example: $0 my_fancy_project"
    exit 1
fi

# Check if new name is a valid Python identifier (POSIX-compliant validation)
case "$NEW_NAME" in
    *[!a-zA-Z0-9_]*)
        echo "Error: '$NEW_NAME' is not a valid Python identifier (only letters, numbers, and underscores)."
        exit 1
        ;;
    [0-9]*)
        echo "Error: '$NEW_NAME' cannot start with a number."
        exit 1
        ;;
esac

OLD_NAME="project_template"

if [ ! -d "$OLD_NAME" ]; then
    echo "Error: Directory '$OLD_NAME' not found."
    echo "Perhaps you have already renamed the project?"
    exit 1
fi

echo "Renaming '$OLD_NAME' to '$NEW_NAME'..."

# Replace text occurrences in files (excluding this script itself)
find . -type f \( -name "*.toml" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name "*.py" -o -name "*.ipynb" \) -not -path '*/.*' -not -name 'setup.sh' | while read -r file; do
    if grep -q "$OLD_NAME" "$file"; then
        echo "Updating references in: $file"
        sed -i "s/$OLD_NAME/$NEW_NAME/g" "$file"
    fi
done

# Rename the actual package directory
mv "$OLD_NAME" "$NEW_NAME"
echo "Success! Renamed package folder to '$NEW_NAME'."

# Cleanup phase: remove AI Coding Style Guide
STYLE_GUIDE="AI_Coding style.md"
if [ -f "$STYLE_GUIDE" ]; then
    echo "Cleaning up '$STYLE_GUIDE'..."
    rm "$STYLE_GUIDE"
fi

# Optional environment setup
if [ "$SETUP" = true ]; then
    echo "\n--- Setting up virtual environment using mamba ---"
    mamba env create -f environment.yml
    
    echo "\n--- Installing package in editable mode ---"
    mamba run -n "$NEW_NAME" pip install -e .
    
    echo "\n--- Registering Jupyter kernel ---"
    mamba run -n "$NEW_NAME" python -m ipykernel install --user --name "$NEW_NAME" --display-name "Python ($NEW_NAME)"
    
    echo "\nSuccess! Project environment setup complete."
    echo "To activate it, run:"
    echo "  mamba activate $NEW_NAME"
else
    echo "\nPlease remember to set up the environment and run pip install:"
    echo "  mamba env create -f environment.yml"
    echo "  mamba activate $NEW_NAME"
    echo "  pip install -e ."
    echo "  python -m ipykernel install --user --name $NEW_name --display-name \"Python ($NEW_name)\""
fi
