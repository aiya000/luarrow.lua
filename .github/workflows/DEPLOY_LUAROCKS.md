# LuaRocks Deployment Workflow

This document explains how to use the automated LuaRocks deployment workflow.

## Overview

The `deploy-luarocks.yml` workflow automatically deploys new versions of the luarrow package to LuaRocks when a new release is published on GitHub.

## Setup

### 1. Set up LuaRocks API Key

To enable automated deployments, you need to configure your LuaRocks API key as a GitHub secret:

1. Get your LuaRocks API key from https://luarocks.org/settings/api-keys
2. Go to your GitHub repository's Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Name: `LUAROCKS_API_KEY`
5. Value: Paste your LuaRocks API key
6. Click "Add secret"

### 2. Prepare for Release

Before creating a new release:

1. Increment the version number:
   ```bash
   make increment-version
   ```

2. Commit the new rockspec file:
   ```bash
   git add luarrow-main-*.rockspec
   git commit -m "chore: bump version to main-X"
   git push
   ```

3. Create a new release on GitHub:
   - Go to Releases → Draft a new release
   - Create a new tag (e.g., `v1.0.0` or `main-X`)
   - Fill in the release title and description
   - Publish the release

### 3. Automatic Deployment

Once you publish the release, the workflow will automatically:

1. Checkout the code
2. Install Lua and LuaRocks
3. Find the latest rockspec file
4. Validate the rockspec by packing it
5. Upload to LuaRocks using your API key
6. Save the built `.src.rock` file as an artifact

## Manual Deployment

You can also trigger the deployment manually using the workflow dispatch:

1. Go to Actions → Deploy to LuaRocks
2. Click "Run workflow"
3. (Optional) Specify a rockspec file, or leave empty to use the latest one
4. Click "Run workflow"

## Troubleshooting

### Error: LUAROCKS_API_KEY secret is not set

Make sure you've added the `LUAROCKS_API_KEY` secret to your repository settings (see Setup step 1).

### Error: No rockspec file found

Ensure you have a `luarrow-*.rockspec` file in the repository root. Run `make increment-version` to create one if needed.

### Upload fails with authentication error

Verify that your LuaRocks API key is valid:
- Check https://luarocks.org/settings/api-keys
- Make sure the key has upload permissions
- Update the GitHub secret with a new key if necessary

## Workflow Triggers

The workflow runs in two scenarios:

1. **On Release**: Automatically when you publish a new release
2. **Manual**: Via workflow dispatch when you need to deploy manually

## What Gets Deployed

The workflow uploads the rockspec file to LuaRocks, which:
- Registers the new version on luarocks.org
- Makes it available via `luarocks install luarrow`
- Provides version-specific installation: `luarocks install luarrow <version>`
