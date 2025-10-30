#!/usr/bin/env bash
# Increment the rockspec version number (e.g. main-1 -> main-2, dev-5 -> dev-6)
# Usage: ./increment-rockspec-version.sh
set -euo pipefail

PROJECT_DIR=$(git rev-parse --show-toplevel 2> /dev/null || exit 1)

# Find the current rockspec file
ROCKSPEC=$(find "$PROJECT_DIR" -maxdepth 1 -name 'luarrow-*.rockspec' -type f | head -n 1)
if [[ -z "$ROCKSPEC" ]]; then
  echo "Error: No luarrow-*.rockspec file found in $PROJECT_DIR"
  exit 1
fi

# Extract current version (e.g. main-1)
CURRENT_VERSION=$(basename "$ROCKSPEC" .rockspec | sed 's/^luarrow-//')

# Parse the version components
if [[ ! "$CURRENT_VERSION" =~ ^([a-z]+)-([0-9]+)$ ]] ; then
  echo "Error: Version format not recognized: $CURRENT_VERSION"
  echo "Expected format: <branch>-<number> (e.g. main-1, dev-2)"
  exit 1
fi

BRANCH="${BASH_REMATCH[1]}"
NUMBER="${BASH_REMATCH[2]}"
NEW_NUMBER=$((NUMBER + 1)) # Increment the number
NEW_VERSION="${BRANCH}-${NEW_NUMBER}"

echo "Current version: $CURRENT_VERSION"
echo "New version: $NEW_VERSION"

# Create new rockspec file with updated version
NEW_ROCKSPEC="$PROJECT_DIR/luarrow-$NEW_VERSION.rockspec"
sed "s/version = '$CURRENT_VERSION'/version = '$NEW_VERSION'/" "$ROCKSPEC" > "$NEW_ROCKSPEC"

echo "Created: $NEW_ROCKSPEC"
rm "$ROCKSPEC"
echo "Removed: $ROCKSPEC"
echo "Version incremented successfully: $CURRENT_VERSION -> $NEW_VERSION"
