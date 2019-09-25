# Preconditions
1. Workspace created
1. Variables set in the workspace

# How to do local development
1. copy `backend.hcl.example` to `backend.hcl`
1. Modify `backend.hcl` with proper **workspace** and **organization** values
   1. **organization** should be your Terraform Cloud organization
   1. workspace should be your dev environment workspace
   1. Example:
   ```hcl
    organization = "my-terraform-cloud-organization"
    workspaces {
        name = "application-dev"
    }
    ```
1. `terraform init -backend-config backend.hcl`
1. `terraform plan`
1. `terraform apply`