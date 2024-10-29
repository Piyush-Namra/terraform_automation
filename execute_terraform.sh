#!/bin/bash

# Define the directory containing your JSON key files and tfvars files
KEY_DIR="./keys"
TFVARS_DIR="./environments"

# Get the current active GCP project ID set by gcloud
CURRENT_PROJECT=$(gcloud config get-value project)

if [ -z "$CURRENT_PROJECT" ]; then
    echo "No project is currently set in gcloud. Please set a project using 'gcloud config set project PROJECT_ID'."
    exit 1
fi

echo "Current active GCP project: $CURRENT_PROJECT"

# Initialize a flag to track if the project is found
PROJECT_FOUND=false

# Get the environment parameter and convert it to lowercase
ENV_PARAM=$(echo "$1" | tr '[:upper:]' '[:lower:]')

if [[ ! "$ENV_PARAM" =~ ^(uat|prod|dev)$ ]]; then
    echo "Invalid environment parameter. Please provide one of the following: uat, prod, dev."
    exit 1
fi

# Define the specific tfvars file to use
TFVARS_FILE="$TFVARS_DIR/$ENV_PARAM.tfvars"

# Check if the tfvars file exists
if [ ! -f "$TFVARS_FILE" ]; then
    echo "The specified tfvars file does not exist: $TFVARS_FILE"
    exit 1
fi

# Extract the project_id from the tfvars file (assumes a variable named project_id is defined)
TFVARS_PROJECT_ID=$(grep -oP '^project_id\s*=\s*"\K[^"]+' "$TFVARS_FILE")
if [ "$TFVARS_PROJECT_ID" != "$CURRENT_PROJECT" ]; then
    echo "The project ID is not matching with the environment paramters passed: $ENV_PARAM"
    exit 1
fi

# Loop over each key.json file in the directory
for KEY_FILE in "$KEY_DIR"/*.json; do
    # Extract the project ID from the key file using python
    PROJECT_ID=$(python -c "import json, sys; print(json.load(sys.stdin)['project_id'])" < "$KEY_FILE")
    echo "google_credentials_file = \"$KEY_FILE\"" > terraform.tfvars

    # Check if the project ID from the key file matches the current active project
    if [ "$PROJECT_ID" == "$CURRENT_PROJECT" ]; then
        PROJECT_FOUND=true
        echo "Matching project ID found: $PROJECT_ID"
        echo "Using service account key: $KEY_FILE"

        # Set Google credentials and project ID environment variables for Terraform
        export GOOGLE_APPLICATION_CREDENTIALS="$KEY_FILE"
        export TF_VAR_project_id="$PROJECT_ID"

        # Check if workspace for this environment exists, if not, create it
        WORKSPACE_EXISTS=$(terraform workspace list | grep -w "$ENV_PARAM")

        if [ -z "$WORKSPACE_EXISTS" ]; then
            echo "Creating new workspace for environment: $ENV_PARAM"
            terraform workspace new "$ENV_PARAM"
        else
            echo "Switching to workspace: $ENV_PARAM"
            terraform workspace select "$ENV_PARAM"
        fi
        # Run Terraform
        terraform init -migrate-state
        # Apply Terraform in the selected workspace
        terraform apply -var-file=$TFVARS_FILE -auto-approve

        if [ $? -ne 0 ]; then
            echo "Terraform deployment failed for environment: $ENV_PARAM"
        else
            echo "Terraform deployment succeeded for environment: $ENV_PARAM"
        fi

        # Optional: Unset credentials for safety
        unset GOOGLE_APPLICATION_CREDENTIALS
        unset TF_VAR_project_id

        break
    fi
done