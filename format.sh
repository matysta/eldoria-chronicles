#!/bin/bash

# ──────────────────────────────────────────────────────────────────────────────
# Script Name: format.sh
# Purpose: This script formats all .gd files in the current directory by removing
#          semicolons and replacing tabs with spaces.
# ──────────────────────────────────────────────────────────────────────────────

echo ""
find . -type f -name "*.gd" | while read -r file; do
    echo "🔄 Processing $file"
    if ! sed -i '' 's/;//g' "$file"; then
        echo "❌ Failed to remove semicolons in file '$file'."
        exit 1
    fi

    if ! sed -i '' 's/\t/    /g' "$file"; then
        echo "❌ Failed to replace tabs in file '$file'."
        exit 1
    fi
done

echo "✅ Formatting complete!"
