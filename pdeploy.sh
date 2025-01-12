#!/bin/bash

# Ensure script exits on errors
set -e

# Parse input arguments
DEBUG=false
if [[ "$*" == *--help* ]]; then
    echo "Usage: ./script.sh [--debug] [--help]"
    echo "Options:"
    echo "  --debug    Run the script in debug mode, displaying each command before execution and asking for confirmation."
    echo "  --help     Show this help message and exit."
    exit 0
elif [[ "$*" == *--debug* ]]; then
    DEBUG=true
fi

# Function to log debug messages
log_debug() {
    if [ "$DEBUG" = true ]; then
        echo "[DEBUG] $1"
    fi
}

# Load environment variables from .env file
log_debug "Loading environment variables from .env file..."
if [ -f .env ]; then
    source .env
else
    echo "Environment file (.env) not found! Exiting."
    exit 1
fi

# Enterprise introduction message
echo "Welcome to the Automated GitHub Workflow Script."
echo "This script facilitates efficient repository management and collaboration tasks."
echo "Developed and maintained by YEL Digital Inc."
echo "All rights reserved."

# Retrieve the current repository name from the remote URL
repoName=$(git config --get remote.origin.url | sed -nE 's#.*[:/](.+)/(.+)\.git#\2#p')

if [ -z "$repoName" ]; then
    echo "Error: Unable to determine repository name. Ensure the repository has a remote URL configured."
    exit 1
fi
echo "Detected repository name: $repoName"

# Function to check Git status
check_git_status() {
    echo "Preliminary Check: Checking Git status..."
    GIT_STATUS=$(git status --porcelain)

    if [ -z "$GIT_STATUS" ]; then
        echo "Git repository is up to date. Skipping to organization authentication."
        return 1
    else
        echo "Git repository has changes. Proceeding with the script."
        return 0
    fi
}

# Function to confirm actions only in debug mode
confirm_action() {
    local message="$1"
    if [ "$DEBUG" = true ]; then
        echo "$message"
        echo "Do you want to run this step? (Y/n)"
        read -r CONFIRM
        CONFIRM=${CONFIRM:-y}
        if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
            echo "Skipping step."
            return 1
        fi
    fi
    return 0
}

# Function to execute commands safely
execute_command() {
    local command="$1"
    if confirm_action "Running command: $command"; then
        log_debug "Executing: $command"
        eval "$command"
    fi
}

# Function to log in to private GitHub account
login_private_account() {
    confirm_action "Logging in to private GitHub account..."
    log_debug "Executing: gh auth login"
    echo "$PRIVATE_TOKEN" | gh auth login --with-token
}

# Function to stage all changes
stage_changes() {
    confirm_action "Staging all changes..."
    git add -A
}

# Function to commit changes with a message
commit_changes() {
    confirm_action "Committing changes..."
    echo "Enter the commit message:"
    read COMMIT_MESSAGE
    git commit -am "$COMMIT_MESSAGE"
}

# Function to push changes to forked repository
push_changes() {
    confirm_action "Pushing changes to forked repository..."
    git push origin main
}

# Function to create a pull request
create_pull_request() {
    confirm_action "Creating a pull request..."
    EXISTING_PR=$(gh pr list --repo "$ORG_NAME/$repoName" --head "$PRIVATE_ACCOUNT:main" --json url --jq '.[0].url')
    if [ -n "$EXISTING_PR" ]; then
        echo "A pull request for branch \"$PRIVATE_ACCOUNT:main\" already exists: $EXISTING_PR"
    else
        PR_TITLE="$COMMIT_MESSAGE"
        if [ -z "$PR_TITLE" ]; then
            echo "Enter the pull request title:"
            read PR_TITLE
        fi
        gh pr create --repo "$ORG_NAME/$repoName" --base main --head "$PRIVATE_ACCOUNT:main" --title "$PR_TITLE" --body "Auto-generated pull request."
    fi
}

# Function to log in to organization GitHub account
login_organization_account() {
    confirm_action "Logging in to organization GitHub account..."
    echo "$ORG_TOKEN" | gh auth login --with-token
}

# Function to list all open pull requests
list_pull_requests() {
    confirm_action "Listing all open pull requests..."
    OPEN_PRS=$(gh pr list --repo "$ORG_NAME/$repoName" --json number,title --jq ".[] | \"#\(.number): \(.title)\"")
    echo "$OPEN_PRS"
}

# Function to merge pull requests
merge_pull_requests() {
    confirm_action "Merging pull request(s)..."
    if [ $(echo "$OPEN_PRS" | wc -l) -eq 1 ]; then
        echo "Only one pull request found. Merging it automatically..."
        PR_NUMBER=$(echo "$OPEN_PRS" | awk -F'#' '{print $2}' | awk -F':' '{print $1}')
        gh pr merge "$PR_NUMBER" --repo "$ORG_NAME/$repoName" --merge
    else
        echo "Multiple pull requests found. Enter the ID of the pull request to merge:"
        echo "$OPEN_PRS"
        read PR_NUMBER
        gh pr merge "$PR_NUMBER" --repo "$ORG_NAME/$repoName" --merge
    fi
}

# Function to log back to private GitHub account
relogin_private_account() {
    confirm_action "Logging back to private GitHub account..."
    echo "$PRIVATE_TOKEN" | gh auth login --with-token
}

# Run the script
check_git_status || {
    create_pull_request
    login_organization_account
    list_pull_requests
    merge_pull_requests
    relogin_private_account
    exit 0
}
login_private_account
stage_changes
commit_changes
push_changes
create_pull_request
login_organization_account
list_pull_requests
merge_pull_requests
relogin_private_account

# Success message
echo ""
echo ""
echo "All steps completed successfully!"
echo "YEL Digital Inc. - All rights reserved."
