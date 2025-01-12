Documentation: How to Use the Scripts
Overview
This documentation provides instructions for using the pnew.sh, pdeploy.sh, and pdelete.sh scripts to manage GitHub repositories efficiently. Ensure that the env file is correctly completed and renamed to .env for the scripts to work.

1. pnew.sh
Purpose: Creates a new repository and sets up the required files.

Usage:

bash
Copy code
./pnew.sh <repository-name>
Details:

The repository will be created in the specified organization and forked to your private GitHub account.
A local folder named after the repository will be created in the current folder location.
Required files (env, pdeploy.sh, pnew.sh) will be added to the repository folder.
Pre-requisites:

Ensure the .env file is correctly configured with your credentials.
Run this script from the location where you want the repository folder to be created.
2. pdeploy.sh
Purpose: Deploys changes to the forked repository and creates pull requests.

Usage:

bash
Copy code
./pdeploy.sh [--debug] [--help]
Options:

--debug: Enables debug mode, requiring confirmation for each step.
--help: Displays the help message.
Details:

This script must be executed within the repository folder created by pnew.sh.
It stages, commits, and pushes changes to the forked repository.
Pull requests are created to merge changes back to the organization's repository.
3. pdelete.sh
Purpose: Deletes a repository from both personal and organizational GitHub accounts.

Usage:

bash
Copy code
./pdelete.sh <repository-name> [--confirm] [--help]
Options:

--confirm: Automatically confirms repository deletions.
--help: Displays the help message.
Details:

This script must be executed from the folder location one level above the repository.
It removes the repository from both the personal and organizational GitHub accounts.
The local repository folder will also be deleted.
4. env File Configuration
The env file contains credentials and settings needed by the scripts. It must be completed and renamed to .env before use.

Example env File:

bash
Copy code
# RENAME THIS FILE TO .env

ORG_NAME="yeldigitalorg"       # Replace with your organization's name
PRIVATE_ACCOUNT="yassinwallace"  # Replace with your private GitHub username
ORG_TOKEN="your-organization-token"  # Add your organization token
PRIVATE_TOKEN="your-private-token"   # Add your private GitHub token
Instructions:

Open the env file in a text editor.
Replace placeholders with the appropriate credentials.
Rename the file to .env and place it in the same directory as the scripts.
Notes
Make sure the GitHub CLI (gh) is installed and authenticated before running these scripts.
The .env file must be present in the script directory and configured correctly for proper execution.