#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Determine the directory of the script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Display script version
VERSION="1.0.0"

# Load environment variables from the .env file
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
else
    echo "Error: Environment file (.env) not found in $SCRIPT_DIR! Exiting."
    exit 1
fi

# Display help message
display_help() {
    echo "Usage: ./pnew.sh [options] <repository-name>"
    echo ""
    echo "Options:"
    echo "  --help       Show this help message and exit"
    echo "  --version    Show the script version and exit"
    echo ""
    echo "Description:"
    echo "This script automates the creation, forking, and setup of GitHub repositories."
    echo "Developed by YEL Digital Inc."
    echo "All rights reserved."
    exit 0
}

# Display version
display_version() {
    echo "pnew.sh version $VERSION"
    exit 0
}

# Process flags and arguments
if [ $# -eq 0 ]; then
    echo "Error: No arguments provided. Use --help for usage information."
    exit 1
fi

# Check for flags
case "$1" in
    --help)
        display_help
        ;;
    --version)
        display_version
        ;;
esac

# Ensure a repository name is provided
if [[ "$1" == --* ]]; then
    echo "Error: Invalid repository name '$1'. Use --help for usage information."
    exit 1
fi

# Variables
REPO_NAME="$1"

# Start script
echo "Welcome to the Automated GitHub Repository Management Script."
echo "Developed by YEL Digital Inc. All rights reserved."

# Step 1: Authenticate with the organization's GitHub account
echo "Step 1: Authenticating with the organization's GitHub account..."
echo "$ORG_TOKEN" | gh auth login --with-token || {
    echo "Error: Failed to authenticate with the organization's GitHub account."
    exit 1
}

# Step 2: Create repository in the organization
echo "Step 2: Creating repository $REPO_NAME in the organization..."
gh repo create "$ORG_NAME/$REPO_NAME" --public --add-readme || {
    echo "Error: Failed to create repository $REPO_NAME."
    exit 1
}

# Step 3: Authenticate with the private GitHub account
echo "Step 3: Authenticating with the private GitHub account..."
echo "$PRIVATE_TOKEN" | gh auth login --with-token || {
    echo "Error: Failed to authenticate with the private GitHub account."
    exit 1
}

# Step 4: Fork the repository
echo "Step 4: Forking the repository $ORG_NAME/$REPO_NAME..."
gh repo fork "$ORG_NAME/$REPO_NAME" --clone --remote || {
    echo "Error: Failed to fork the repository $REPO_NAME."
    exit 1
}

# Step 5: Set the fork as the default repository
echo "Step 5: Setting the fork as the default repository..."
cd "$REPO_NAME"
gh repo set-default "$PRIVATE_ACCOUNT/$REPO_NAME" || {
    echo "Error: Failed to set the fork as the default repository."
    exit 1
}

# Step 6: Add required files to the repository
echo "Step 6: Adding required files to the repository..."
cp "$SCRIPT_DIR/env" env
cp "$SCRIPT_DIR/pdeploy.sh" pdeploy.sh
cp "$SCRIPT_DIR/pnew.sh" pnew.sh
cp "$SCRIPT_DIR/pdelete.sh" pdelete.sh
cp "$SCRIPT_DIR/.gitignore" .gitignore
cp -f "$SCRIPT_DIR/README.md" README.md

# Final success message
echo "All steps completed successfully!"
echo "YEL Digital Inc. - All rights reserved."
