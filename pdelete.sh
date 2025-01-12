#!/bin/bash

# Ensure script exits on errors
set -e

# Function to display help message
show_help() {
    echo "Usage: ./script.sh <project-name> [--yes] [--help]"
    echo "Options:"
    echo "  --yes   Automatically confirm repository deletions."
    echo "  --help      Display this help message and exit."
    exit 0
}

# Parse input arguments
CONFIRM=false
PROJECT_NAME=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            show_help
            ;;
        --yes)
            CONFIRM=true
            shift
            ;;
        *)
            if [ -z "$PROJECT_NAME" ]; then
                PROJECT_NAME="$1"
            else
                echo "Error: Multiple project names provided. Usage: ./script.sh <project-name> [--yes] [--help]"
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if the project name is provided
if [ -z "$PROJECT_NAME" ]; then
    echo "Error: Project name not provided. Usage: ./script.sh <project-name> [--yes] [--help]"
    exit 1
fi

# Variables
DELETE_FLAG=""
if [ "$CONFIRM" = true ]; then
    DELETE_FLAG="--yes"
fi

# Delete repository in the personal account
echo "Deleting repository yassinwallace/$PROJECT_NAME..."
gh repo delete "yassinwallace/$PROJECT_NAME" $DELETE_FLAG

# Switch authentication and delete the organization repository
echo "Switching authentication and deleting repository yeldigitalorg/$PROJECT_NAME..."
gh auth switch
gh repo delete "yeldigitalorg/$PROJECT_NAME" $DELETE_FLAG

# Switch authentication back and clean up local files
echo "Switching authentication back and cleaning up local files..."
gh auth switch
rm -rf "$PROJECT_NAME/"

echo "All operations completed successfully!"
