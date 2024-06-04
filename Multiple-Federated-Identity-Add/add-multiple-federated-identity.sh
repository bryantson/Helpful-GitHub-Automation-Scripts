#!/usr/bin/env bash

echo "ADD multiple GitHub Actions repositories to Federated Identity in Azure App Registration"

# Give a default name that will give a basis for the file name:
DEFAULT_FILENAME=credential

# Type your organization name:
ORGANIZATION=

# Your GitHub PAT token with repo permission. Make sure to authorize for your SSO:
GITHUB_TOKEN=

# Your Application ID or Object ID from Azure Application Registration:
APP_ID=

# Will use to create federated idenity:
REPO_FILE_NAME=[]

################################################################################
#### Function Create Federated Identity  #######################################
# REFERENCE: https://learn.microsoft.com/en-us/cli/azure/ad/app/federated-credential?view=azure-cli-latest#az-ad-app-federated-credential-create
# 
function CreateFederatedIdentity {
  echo ""
  echo "====================================================================="
  echo "============= Create Federated Identity in Azure AD   ==============="
  echo "====================================================================="
  echo ""

  # Loop through REPO_FILE_NAME and run the following command to create a new federated identity for each repository:
for file in "${REPO_FILE_NAME[@]}"; do
  echo "Creating a new federated identity for the repository: ${file}"
  az ad app federated-credential create --id ${APP_ID} --parameters @"${file}"
done
}

################################################################################
#### Function Create new JSON file  ##################################################
function CreateNewJSONFile {
  echo ""
  echo "====================================================================="
  echo "============= Create a JSON file with Azure FI info   ==============="
  echo "====================================================================="
  echo ""

  echo "You decided to create a new JSON file that contains the federated identity information for each repository."
  echo "This will be stored under the following file: [${DEFAULT_FILENAME}]-repository_name.json"

 # Loop through the response file and add a JSON block per repository in the following format to the file named $FILE_NAME
 # {
 #  "name": repo_name,
#   "issuer": "https://token.actions.githubusercontent.com/",
#   "subject": "repo:${ORGANIZATION}/${repo_name}:refs/heads/main",
#   "description": repository_description, 
#   "audiences": ["api://AzureADTokenExchange"],
# }
#
# Export file name will be named as $FILE_NAME concatenated with repository name

for row in $(echo "$RESPONSE_REPOS" | jq -r '.[] | @base64'); do
  _jq() {
    echo "${row}" | base64 --decode | jq -r "${1}"
  }

  # Remove the file if it exists
  rm -f "./${DEFAULT_FILENAME}-$(_jq '.name').json"

 # Echo repository name:
  echo "Repository name: $(_jq '.name')"

    echo "{
    \"name\": \"$(_jq '.name')\",
    \"issuer\": \"https://token.actions.githubusercontent.com/\",
    \"subject\": \"repo:${ORGANIZATION}/$(_jq '.name'):refs/heads/main\",
    \"description\": \"$(_jq '.description')\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }" >> "./${DEFAULT_FILENAME}-$(_jq '.name').json"

    REPO_FILE_NAME+=("${DEFAULT_FILENAME}-$(_jq '.name').json")

done

# Remove first item from REPO_FILE_NAME array
REPO_FILE_NAME=("${REPO_FILE_NAME[@]:1}")

# Print out from REPO_FILE_NAME through loop:
for file in "${REPO_FILE_NAME[@]}"; do
  echo "Created file: ${file}"
done

  echo "Done creating file named [$DEFAULT_FILENAME]"
}

################################################################################
#### Function Repository Analysis ##################################################
function RepositoryAnalysis {
  echo ""
  echo "====================================================================="
  echo "============= Repository Analysis  ==============="
  echo "====================================================================="
  echo ""

  echo "Now, let's run through different organizations in this organization: ${ORGANIZATION}"
  
  # Run cURL command to start an export job of the repositories on GitHub.com
  RESPONSE_REPOS=$(curl -H "Authorization: token ${GITHUB_TOKEN}" -X GET \
    -H "Accept: application/vnd.github.wyandotte-preview+json" \
    -sS "https://api.github.com/orgs/${ORGANIZATION}/repos" )

  echo "We found the following repositories:"
  
  COUNTER_REPO=1

  for row in $(echo "$RESPONSE_REPOS" | jq -r '.[] | @base64'); do
    _jq() {
      echo "${row}" | base64 --decode | jq -r "${1}"
    }
    echo "${COUNTER_REPO} : " "$(_jq '.name')"
    COUNTER_REPO=$((COUNTER_REPO+1))
  done
}


## MAIN FUNCTION CALLS

RepositoryAnalysis

CreateNewJSONFile

CreateFederatedIdentity
