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

        # Search for the matching .tfvars file in the environments directory
        for TFVARS_FILE in "$TFVARS_DIR"/*.tfvars; do
            # Extract the project_id from the tfvars file (assumes a variable named project_id is defined)
            TFVARS_PROJECT_ID=$(grep -oP '^project_id\s*=\s*"\K[^"]+' "$TFVARS_FILE")

            if [ "$TFVARS_PROJECT_ID" == "$PROJECT_ID" ]; then
                echo "Matching tfvars file found: $TFVARS_FILE"
                
                # Extract the environment label from the tfvars file (assumes label["environment"] is defined)
                ENVIRONMENT=$(grep -oP 'labels\s*=\s*{[^}]*environment\s*=\s*"\K[^"]+' "$TFVARS_FILE")
                echo $ENVIRONMENT
                echo $TFVARS_FILE
                if [ -z "$ENVIRONMENT" ]; then
                    echo "No environment label found in $TFVARS_FILE"
                    exit 1
                fi

#                 echo "Environment for project $PROJECT_ID: $ENVIRONMENT"

#                 # Initialize Terraform with the HCP backend and project-specific workspace
#                 cat > backend_override.tf <<- EOM
#                 terraform {
#                   backend "hcp" {
#                     organization = "your_hcp_organization"
#                     project      = "your_hcp_project"
#                     workspaces {
#                       name = "${ENVIRONMENT}"
#                     }
#                   }
#                 }
# EOM

                # # Initialize Terraform with the updated backend configuration
                # terraform init -reconfigure

                # Check if workspace for this environment exists, if not, create it
                WORKSPACE_EXISTS=$(terraform workspace list | grep -w "$ENVIRONMENT")

                if [ -z "$WORKSPACE_EXISTS" ]; then
                    echo "Creating new workspace for environment: $ENVIRONMENT"
                    terraform workspace new "$ENVIRONMENT"
                else
                    echo "Switching to workspace: $ENVIRONMENT"
                    terraform workspace select "$ENVIRONMENT"
                fi
                # Run Terraform
                terraform init -migrate-state
                # Apply Terraform in the selected workspace
                terraform apply -var-file=$TFVARS_FILE -auto-approve

                if [ $? -ne 0 ]; then
                    echo "Terraform deployment failed for environment: $ENVIRONMENT"
                else
                    echo "Terraform deployment succeeded for environment: $ENVIRONMENT"
                fi

                # Optional: Unset credentials for safety
                unset GOOGLE_APPLICATION_CREDENTIALS
                unset TF_VAR_project_id

                break
            fi
        done

        if [ "$PROJECT_FOUND" = false ]; then
            echo "No matching tfvars file found for project ID: $CURRENT_PROJECT"
            exit 1
        fi

        break
    fi
done

if [ "$PROJECT_FOUND" = false ]; then
    echo "No matching key.json found for the current project ID: $CURRENT_PROJECT"
    exit 1
fi