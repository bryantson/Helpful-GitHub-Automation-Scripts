# Bash script to add multiple GitHub repositories as federated identities to Azure Application registration's app

## Introduction
This script is used to add multiple federated identities for GitHub repository to an Azure Application registration's app. The script uses the Azure CLI to add the federated identities to the app.

This is useful if you want to have all repositories in a GitHub organization to be able to access an Azure Application registration's app. Sinec the Azure Application registration's app can only have one federated identity, this script can be used to add multiple federated identities to the app.

## Prerequisites

1. Install Azure CLI. You can find the instructions to install Azure CLI [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
2. You need to have an Azure account with an active subscription.
3. You need to have JQ installed. You can find the instructions to install JQ [here](https://stedolan.github.io/jq/download/).
4. You need to have a GitHub PAT (Personal Access Token) with `repo` scope. You can find the instructions to create a PAT [here](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token).
5. You need to run this in a bash environment. If you are using Windows, you can use GIT CLI which has a bash environment.
6. Download the script `add-federated-identities.sh` from this folder.

## How to run the script

1. Make sure that you are logged into Azure CLI:

```bash
az login
```

2. Change the values of the variables in the script as per your requirements.

| Variable Name | Description | Required to change ? |
| ------------- | ----------- | ---------- |
| ORGANIZATION | The name of the GitHub organization where the repository is located. | Yes |
| GITHUB_TOKEN | The GitHub PAT (Personal Access Token) with `repo` scope. | Yes |
| APP_ID | The Application (client) ID of the Azure AD app. | Yes |
| DEFAULT_FILENAME | The default filename of the JSON file containing the federated identities. | No |

3. Make sure that the script becomes executable:

```bash
chmod +x add-federated-identities.sh
```

4. Run the script:

```bash
./add-federated-identities.sh
```

5. Verify that the federated identities are added to the Azure Application registration's app.

# Not tested version

Powershell version is not properly tested yet.

[add-multiple-federated-identity.ps1](add-multiple-federated-identity.ps1) is the powershell version of the script. You can run this script in a powershell environment.
