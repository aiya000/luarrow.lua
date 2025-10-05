#!/bin/bash

set -euo pipefail

# Usage: ./scripts/release.sh <version>
# Example: ./scripts/release.sh 1.0.0

if [ $# -eq 0 ]; then
    echo "Error: Version number required"
    echo "Usage: ./scripts/release.sh <version>"
    echo "Example: ./scripts/release.sh 1.0.0"
    exit 1
fi

VERSION=$1

echo "==> Releasing luarrow.lua version $VERSION"

# 1. Check if working directory is clean
if [ -n "$(git status --porcelain)" ]; then
    echo "Error: Working directory is not clean. Commit or stash your changes first."
    git status --short
    exit 1
fi

# 2. Run tests and linting
echo "==> Running tests and linting..."
make check

# 3. Update rockspec file
echo "==> Creating rockspec for version $VERSION..."
ROCKSPEC_FILE="luarrow-$VERSION-1.rockspec"

cat > "$ROCKSPEC_FILE" << 'ROCKSPEC_EOF'
package = 'luarrow'
version = '$VERSION-1'
source = {
   url = 'git+https://github.com/aiya000/luarrow.lua',
   tag = 'v$VERSION'
}
description = {
   summary = 'Haskell-style function composition and application for Lua',
   detailed = [[
      luarrow.lua brings the elegance of Haskell's function composition to Lua
      with beautiful operator overloading. Write `fun(f) * fun(g) % x` instead
      of `f(g(x))` and make your functional pipelines readable and maintainable.

      Features:
      - Haskell-inspired syntax with * for composition and % for application
      - Zero dependencies - pure Lua implementation
      - Minimal overhead with simple table wrapping
   ]],
   homepage = 'https://github.com/aiya000/luarrow.lua',
   license = 'MIT'
}
dependencies = {
   'lua >= 5.1'
}
build = {
   type = 'builtin',
   modules = {
      luarrow = 'src/luarrow.lua'
   },
   copy_directories = {
      'doc'
   }
}
ROCKSPEC_EOF

# Replace variables in rockspec
sed -i "s/\$VERSION/$VERSION/g" "$ROCKSPEC_FILE"

# 4. Build and test the rockspec
echo "==> Building rockspec..."
luarocks pack "$ROCKSPEC_FILE"

# 5. Commit the rockspec
echo "==> Committing rockspec..."
git add "$ROCKSPEC_FILE"
git commit -m "Release version $VERSION"

# 6. Create git tag
echo "==> Creating git tag v$VERSION..."
git tag -a "v$VERSION" -m "Release version $VERSION"

# 7. Push to remote
echo "==> Pushing to remote..."
git push origin main
git push origin "v$VERSION"

# 8. Upload to LuaRocks (if API key is set)
if [ -n "${LUAROCKS_API_KEY:-}" ]; then
    echo "==> Uploading to LuaRocks..."
    luarocks upload "$ROCKSPEC_FILE" --api-key="$LUAROCKS_API_KEY"
else
    echo "==> Skipping LuaRocks upload (LUAROCKS_API_KEY not set)"
    echo "    To upload manually, run:"
    echo "    luarocks upload $ROCKSPEC_FILE --api-key=YOUR_API_KEY"
fi

echo ""
echo "==> Release complete! 🎉"
echo "    Version: $VERSION"
echo "    Tag: v$VERSION"
echo "    Rockspec: $ROCKSPEC_FILE"
