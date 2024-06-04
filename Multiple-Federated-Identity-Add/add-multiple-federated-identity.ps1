Write-Host "ADD multiple GitHub Actions repositories to Federated Identity in Azure App Registration"

# Give a default name that will give a basis for the file name:
$DEFAULT_FILENAME="credential"

# Type your organization name:
$ORGANIZATION=""

# Your GitHub PAT token with repo permission. Make sure to authorize for your SSO:
$GITHUB_TOKEN=""

# Your Application ID or Object ID from Azure Application Registration:
$APP_ID=""

# Will use to create federated idenity:
$REPO_FILE_NAME=@()

################################################################################
#### Function Create Federated Identity  #######################################
function CreateFederatedIdentity {
  Write-Host ""
  Write-Host "====================================================================="
  Write-Host "============= Create Federated Identity in Azure AD   ==============="
  Write-Host "====================================================================="
  Write-Host ""

  # Loop through REPO_FILE_NAME and run the following command to create a new federated identity for each repository:
  foreach ($file in $REPO_FILE_NAME) {
    Write-Host "Creating a new federated identity for the repository: $file"
    az ad app federated-credential create --id $APP_ID --parameters @"$file"
  }
}

################################################################################
#### Function Create new JSON file  ##################################################
function CreateNewJSONFile {
  Write-Host ""
  Write-Host "====================================================================="
  Write-Host "============= Create a JSON file with Azure FI info   ==============="
  Write-Host "====================================================================="
  Write-Host ""

  Write-Host "You decided to create a new JSON file that contains the federated identity information for each repository."
  Write-Host "This will be stored under the following file: [$DEFAULT_FILENAME]-repository_name.json"

  # Loop through the response file and add a JSON block per repository in the following format to the file named $FILE_NAME
  foreach ($row in $RESPONSE_REPOS) {
    $repo_name = $row.name
    $repository_description = $row.description

    # Remove the file if it exists
    Remove-Item -Path "./$DEFAULT_FILENAME-$repo_name.json" -ErrorAction Ignore

    # Echo repository name:
    Write-Host "Repository name: $repo_name"

    $jsonContent = @"
    {
      "name": "$repo_name",
      "issuer": "https://token.actions.githubusercontent.com/",
      "subject": "repo:$ORGANIZATION/$repo_name:refs/heads/main",
      "description": "$repository_description",
      "audiences": ["api://AzureADTokenExchange"]
    }
"@
    $jsonContent | Out-File -FilePath "./$DEFAULT_FILENAME-$repo_name.json"

    $REPO_FILE_NAME += "$DEFAULT_FILENAME-$repo_name.json"
  }

  # Print out from REPO_FILE_NAME through loop:
  foreach ($file in $REPO_FILE_NAME) {
    Write-Host "Created file: $file"
  }

  Write-Host "Done creating file named [$DEFAULT_FILENAME]"
}

################################################################################
#### Function Repository Analysis ##################################################
function RepositoryAnalysis {
  Write-Host ""
  Write-Host "====================================================================="
  Write-Host "============= Repository Analysis  ==============="
  Write-Host "====================================================================="
  Write-Host ""

  Write-Host "Now, let's run through different organizations in this organization: $ORGANIZATION"

  # Run Invoke-RestMethod command to start an export job of the repositories on GitHub.com
  $RESPONSE_REPOS = Invoke-RestMethod -Headers @{"Authorization"="token $GITHUB_TOKEN"} -Uri "https://api.github.com/orgs/$ORGANIZATION/repos"

  Write-Host "We found the following repositories:"

  $COUNTER_REPO=1

  foreach ($row in $RESPONSE_REPOS) {
    Write-Host "$COUNTER_REPO : " $row.name
    $COUNTER_REPO++
  }
}

## MAIN FUNCTION CALLS

RepositoryAnalysis

CreateNewJSONFile

CreateFederatedIdentity
