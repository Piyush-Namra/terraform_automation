### PEC-Infra utility
This approach uses **workspaces** to logically separate environments (`dev`, `uat`, `prod`) while loading environment-specific variable files to handle configuration differences.
#### 1. **Use Terraform Workspaces**
Workspaces provide logical isolation for each environment without needing multiple directories or `main.tf` files.

- **Create workspaces** for each environment:
  
  ```bash
  terraform workspace new dev
  terraform workspace new uat
  terraform workspace new prod
  ```

- **Switch to the desired workspace** when deploying or managing infrastructure:

  ```bash
  terraform workspace select dev
  terraform apply -var-file="dev.tfvars"

  terraform workspace select uat
  terraform apply -var-file="uat.tfvars"

  terraform workspace select prod
  terraform apply -var-file="prod.tfvars"
  ```
