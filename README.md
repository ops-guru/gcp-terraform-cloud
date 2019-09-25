# gcp-terraform-cloud
Goal of this terraform code is to stand up working environments, from scratch, following best practices. All the 
environments are almost identical and setup around GKE as a core for application deployments. All the code is
designed to work with terraform cloud. Terraform code is structured to be deployed in various workspaces. Please see 
[this link](https://www.terraform.io/docs/cloud/workspaces/repo-structure.html#structuring-repos-for-multiple-environments) 
on how to organize the code for terraform cloud. The following list shows what resources are deployed in which folder:
1. infra-host-project
   1. Environment Directory
   1. Project that hosts a VPC
   1. Shared VPC
   1. Cloud NAT
1. infra-service-project
   1. Service Project that uses shared VPC created above.
   1. Service accounts for various current and future application and resources
1. security
   1. IAM bindings for service accounts created above and for admin, secops, and viewer groups
   1. Firewall rules
1. application
   1. private GKE cluster
   1. gke bastion host that can be used to access the GKE cluster 

Order of deployment is `infra-host-project` -> `infra-service-project` -> `security` -> `application`

# Prerequistes
Following are the prerequisites necessary for successful deployment of resources.
 
### 1. github
Before you start deploying this code i would strongly recommend that you clone this repo to your own github account.

### 2. terraform cloud
1. You will need to create a terraform cloud account at https://app.terraform.io
1. Once you have your account, create a token and store it in ~/.terraformrc. Please see: https://www.terraform.io/docs/cloud/free/index.html#configure-access-for-the-terraform-cli
1. In Terraform UI create an organization. See: https://www.terraform.io/docs/cloud/free/index.html#create-an-organization
1. Once you have your organization, connect your github account with terraform cloud. Follow these instructions: https://www.terraform.io/docs/cloud/vcs/github.html
1. Now that you have your organization and github oath_token_id export set the environment variables like this:
   ```bash
   export TF_CLOUD_ORG=<Your Cloud Organization Name>
   export TF_CLOUD_OAUTH_TOKEN_ID=<OAuth Token ID>
   ```

### 3. GCP
1. Create a project called bootstrap-gcp-lz
1. Enable the following APIs if they are not enabled:
   * iam.googleapis.com
   * container.googleapis.com
   * cloudresourcemanager.googleapis.com
1. Create a service account called `bootstrap`
1. Assign the following roles to `bootstrap` service account:
   * `Billing Account User` on the org level
   * `Compute Shared VPC Admin` on the org level
   * `Folder Creator` on the org level
   * `Organization Viewer` on the org level
   * `Project Creator` on the org level
   * `Owner` on the project level
1. Create a key-pair credentials for the `bootstrap` service account. (It will be downloaded to your computer)
1. Place the credentials file in the root of this repo and rename it to `credentials.json`

# Deployment procedure
You must complete all the steps in **Prerequistes** section. It is very important that you set these:
```bash
export TF_CLOUD_ORG=<Your Cloud Organization Name>
export TF_CLOUD_OAUTH_TOKEN_ID=<OAuth Token ID>
```

## 1. Deploy Workspaces
1. `cd workspaces`
1. `./create-workspaces.py --org $TF_CLOUD_ORG --oauth_token_id $TF_CLOUD_OAUTH_TOKEN_ID`
   * This will create workspaces per environment. For example the there will be three workspaces for infra-host-project:
     infra-host-project-dev, infra-host-project-stg, infra-host-project-prd
   * workspace details are in workspaces.yaml
1. `./pushvars.py --org $TF_CLOUD_ORG *.hcl`
   * This will populate variables for each workspace created in the previous step

## 2. Update org_id and billing_account_id
We treat GCP organization ID and Billing Account Id as sensitive information, therefore those values should not be
committed to a git repo.
1. Go to your terraform cloud UI.
1. Manually add the following variables in infra-host-project-dev, infra-host-project-stg, infra-host-project-prd, 
infra-service-project-dev, infra-service-project-stg, infra-service-project-prd:
   * org_id = <your gcp organization ID>
   * billing_account_id = <your organization billing account id>
   
## 3. Deploy dev environment
Dev environment is meant for terraform code development. Workspaces for dev environment are not connected to VCS though
they can be if you want. (modify workspaces/workspaces.yaml if you want this feature enabled on dev)

1. Deploy infra-host-project
   1. `cd infra-host-project`
   1. `cp backend.hcl.example backend.hcl`
   1. Modify `backend.hcl` with proper information
   ```hcl
    organization = "<my-terraform-cloud-organization>"
    workspaces {
        name = "infra-host-project-dev"
    }
   ```
   1. `terraform init -backend-config backend.hcl`
   1. `terraform plan`
   1. `terraform apply`
1. Deploy infra-service-project
   1. `cd infra-host-project`
   1. `cp backend.hcl.example backend.hcl`
   1. Modify `backend.hcl` with proper information
   ```hcl
    organization = "<my-terraform-cloud-organization>"
    workspaces {
        name = "infra-service-project-dev"
    }
   ```
   1. `terraform init -backend-config backend.hcl`
   1. `terraform plan`
   1. `terraform apply`
1. Deploy infra-service-project
   1. `cd infra-service-project`
   1. `cp backend.hcl.example backend.hcl`
   1. Modify `backend.hcl` with proper information
   ```hcl
    organization = "<my-terraform-cloud-organization>"
    workspaces {
        name = "infra-service-project-dev"
    }
   ```
   1. `terraform init -backend-config backend.hcl`
   1. `terraform plan`
   1. `terraform apply`
1. Deploy security
   1. `cd security`
   1. `cp backend.hcl.example backend.hcl`
   1. Modify `backend.hcl` with proper information
   ```hcl
    organization = "<my-terraform-cloud-organization>"
    workspaces {
        name = "security-dev"
    }
   ```
   1. `terraform init -backend-config backend.hcl`
   1. `terraform plan`
   1. `terraform apply`
1. Deploy security
   1. `cd security`
   1. `cp backend.hcl.example backend.hcl`
   1. Modify `backend.hcl` with proper information
   ```hcl
    organization = "<my-terraform-cloud-organization>"
    workspaces {
        name = "security-dev"
    }
   ```
   1. `terraform init -backend-config backend.hcl`
   1. `terraform plan`
   1. `terraform apply`
1. Deploy application
   1. `cd application`
   1. `cp backend.hcl.example backend.hcl`
   1. Modify `backend.hcl` with proper information
   ```hcl
    organization = "<my-terraform-cloud-organization>"
    workspaces {
        name = "application-dev"
    }
   ```
   1. `terraform init -backend-config backend.hcl`
   1. `terraform plan`
   1. `terraform apply`

## 3. Deploy stg and prd environments
These environments can be deployed via terraform UI.
1. Go to your terraform cloud UI
1. Go to your organization
1. Queue up the following workspaces in this particular order:
   1. infra-host-project-stg
   1. infra-service-project-stg
   1. security-stg
   1. application-stg
1. Repeat the same for production environment

Staging and Production workspaces are connected to VCS repo and will be triggered if there is any changes in their 
respective directories. These environments are designed in this manner so that there are no manual deployment to staging
and production. These environments should always be deployed/redeployed via UI on PRs or other change requests.
