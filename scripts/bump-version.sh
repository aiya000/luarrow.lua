#!/bin/bash
set -e

# chotto.lua version bump script
# Usage: ./bump-version.sh [new_version]
# Example: ./bump-version.sh 15

# Check if version argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <new_version_number>"
    echo "Example: $0 15"
    exit 1
fi

NEW_VERSION="$1"

# Find current rockspec file
CURRENT_ROCKSPEC=$(ls *.rockspec 2>/dev/null | head -1)
if [ -z "$CURRENT_ROCKSPEC" ]; then
    echo "Error: No .rockspec file found!"
    exit 1
fi

# Extract current version number
CURRENT_VERSION=$(basename "$CURRENT_ROCKSPEC" .rockspec | sed 's/chotto-main-//')
echo "Current version: main-$CURRENT_VERSION"
echo "New version: main-$NEW_VERSION"

# Create new rockspec filename
NEW_ROCKSPEC="chotto-main-$NEW_VERSION.rockspec"

# Check if new version already exists
if [ -f "$NEW_ROCKSPEC" ]; then
    echo "Error: $NEW_ROCKSPEC already exists!"
    exit 1
fi

# Create new rockspec file with updated version
echo "Creating $NEW_ROCKSPEC..."
sed "s/version = 'main-$CURRENT_VERSION'/version = 'main-$NEW_VERSION'/" "$CURRENT_ROCKSPEC" > "$NEW_ROCKSPEC"

# Remove old rockspec file
echo "Removing old $CURRENT_ROCKSPEC..."
rm "$CURRENT_ROCKSPEC"

# Remove old .src.rock file if exists
OLD_ROCK_FILE="chotto-main-$CURRENT_VERSION.src.rock"
if [ -f "$OLD_ROCK_FILE" ]; then
    echo "Removing old $OLD_ROCK_FILE..."
    rm "$OLD_ROCK_FILE"
fi

echo "Version bump completed!"
echo "Next steps:"
echo "1. make build"
echo "2. make upload"
echo ""
echo "Or run: ./release.sh $NEW_VERSION"