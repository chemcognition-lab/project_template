#!/bin/sh

# Usage:
#   ./setup_project.sh <new_project_name>
#
# Examples:
#   ./setup_project.sh my_fancy_project

# Exit immediately if a command exits with a non-zero status
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <new_project_name>"
    echo "Example: $0 my_fancy_project"
    exit 1
fi

NEW_NAME="$1"

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
find . -type f \( -name "*.toml" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name "*.py" -o -name "*.ipynb" \) -not -path '*/.*' -not -name 'setup_project.sh' | while read -r file; do
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


echo "\nRunning environment setup..."
exec ./setup.sh


# Replace README.md with the minimal project template README
if [ -f "README_template.md" ]; then
    echo "Replacing README.md with minimal project template..."
    mv README_template.md README.md
fi

# Self-destruct: delete this script as it is only needed once
rm "$0"