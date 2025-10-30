#!/usr/bin/env bash
# Repackage .src.rock that contains a single top-level directory (e.g. luarrow.lua/)
# into a .src.rock whose contents are the inner directory contents (so src/... is top-level).
# Usage: ./repack-src-rock.sh [input.src.rock] [output.src.rock]
set -euo pipefail

PROJECT_DIR=$(git rev-parse --show-toplevel 2> /dev/null || exit 1)

# Auto-detect revision (e.g. main-1, main-2, dev-1, etc.)
ROCKSPEC=$(find "$PROJECT_DIR" -maxdepth 1 -name 'luarrow-*.rockspec' -type f | head -n 1)
if [[ -z "$ROCKSPEC" ]]; then
  echo "Error: No luarrow-*.rockspec file found in $PROJECT_DIR"
  exit 1
fi
REVESION=$(basename "$ROCKSPEC" .rockspec | sed 's/^luarrow-//')
echo "Detected revision: $REVESION"
exit

SRC=luarrow-$REVESION.src.rock
OUT=luarrow-$REVESION.fixed.src.rock
PROJECT_DIR_NAME=luarrow.lua

SRC_PATH="$PROJECT_DIR/$SRC"

# prerequisites: unzip, zip
command -v unzip >/dev/null 2>&1 || {
  echo 'unzip not found'
  exit 1
}
command -v zip >/dev/null 2>&1 || {
  echo 'zip not found'
  exit 1
}

if [[ -d $OUT ]] ; then
  rm "$OUT" || exit 1
fi


TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"

unzip -q "$SRC_PATH"
if [[ ! -d $PROJECT_DIR_NAME ]] ; then
  echo "Expected directory '$PROJECT_DIR_NAME' not found in archive $SRC"
  exit 1
fi
cd "$PROJECT_DIR_NAME"
rm -rf "$PROJECT_DIR_NAME"

zip -r -q "$PROJECT_DIR/$OUT" .
echo "Created: $PWD/../$OUT (from archive $SRC)"

rm "$PROJECT_DIR/$SRC"
echo "Original Deleted: $PROJECT_DIR/$SRC"

mv "$PROJECT_DIR/$OUT" "$PROJECT_DIR/$SRC"
echo "Replaced '$PROJECT_DIR/$SRC' with '$PROJECT_DIR/$OUT'"
