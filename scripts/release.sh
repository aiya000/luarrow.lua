#!/bin/bash
set -e

# luarrow.lua full release script
# Usage: ./release.sh [new_version]
# Example: ./release.sh 9

# Check if version argument is provided
if [[ $# -ne 1 ]] ; then
    echo "Usage: $0 <new_version_number>"
    echo "Example: $0 15"
    exit 1
fi

NEW_VERSION="$1"

echo "🚀 Starting release process for version main-$NEW_VERSION"
echo ""

# Step 1: Run tests
echo "📋 Step 1: Running tests..."
make test
echo "✅ Tests passed!"
echo ""

# Step 2: Run lint
echo "🔍 Step 2: Running lint..."
make lint
echo "✅ Lint passed!"
echo ""

# Step 3: Bump version
echo "📦 Step 3: Bumping version..."
if [[ -f luarrow-main-$NEW_VERSION.rockspec ]] ; then
  echo "luarrow-main-$NEW_VERSION.rockspec already exists. Skip."
else
  ./scripts/bump-version.sh "$NEW_VERSION"
fi
echo "✅ Version bumped!"
echo ""

# Step 4: Build
echo "🔨 Step 4: Building..."
make build
echo "✅ Build completed!"
echo ""

# Step 5: Upload
echo "🚀 Step 5: Uploading to LuaRocks..."
if [ -z "$LUAROCKS_CHOTTO_LUA_API_KEY" ]; then
    echo "❌ Error: LUAROCKS_CHOTTO_LUA_API_KEY environment variable is not set!"
    echo "Please set your LuaRocks API key:"
    echo "export LUAROCKS_CHOTTO_LUA_API_KEY=your_api_key_here"
    exit 1
fi

make upload
echo "✅ Upload completed!"
echo ""

echo "🎉 Release main-$NEW_VERSION completed successfully!"
echo ""
echo "📋 Summary:"
echo "- Version: main-$NEW_VERSION"
echo "- Rockspec: luarrow-main-$NEW_VERSION.rockspec"
echo "- Rock file: luarrow-main-$NEW_VERSION.src.rock"
echo ""
echo "🔗 Check your release at:"
echo "https://luarocks.org/modules/aiya000/luarrow"
