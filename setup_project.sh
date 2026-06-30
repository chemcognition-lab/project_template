#!/bin/sh

# Usage:
#   ./setup_project.sh <new_project_name>
#
# Examples:
#   ./setup_project.sh my_fancy_project

# Exit immediately if a command exits with a non-zero status
set -e

# Globals
OLD_NAME="project_template"
STYLE_GUIDE="AI_Coding style.md"
NEW_NAME="$1"

if [ -z "$NEW_NAME" ]; then
    echo "Usage: $0 <new_project_name>"
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

# Rename package folder
mv "$OLD_NAME" "$NEW_NAME"
echo "Success! Renamed package folder to '$NEW_NAME'."

# Cleanup AI coding style guide
echo "Cleaning up '$STYLE_GUIDE'..."
rm "$STYLE_GUIDE"

# Replace README.md with the minimal project template README
echo "Replacing README.md with minimal project template..."
mv README_template.md README.md

# Self-destruct: delete this script as it is only needed once
echo "Self-deleting setup_project.sh..."
rm "$0"

echo "\nRunning environment setup..."
exec ./setup.sh
