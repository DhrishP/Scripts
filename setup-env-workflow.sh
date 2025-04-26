#!/bin/bash
# setup-env-workflow.sh

# Create the workflow directory
mkdir -p .github/workflows

# Create the workflow file
cat > .github/workflows/store-env.yml << 'EOL'
name: Store ENV File

on:
  workflow_dispatch:
  push:
    paths:
      - '.env'
      - '.dev.vars'

jobs:
  store-env:
    uses: DhrishP/env-storage/.github/workflows/store-env-reusable.yml@main
    secrets:
      ENV_PAT: ${{ secrets.ENV_PAT }}
EOL

echo "Workflow file created at .github/workflows/store-env.yml"
