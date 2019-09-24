variable "credentials" {
  description = "Path to service account credentials"
}

variable "environment" {
  description = "Environment. Valid values are dev, stg, and prd"
}

variable "terraform_organization" {
  description = "Terraform Organization that holds all workspaces"
}

variable "region" {
  description = "Region where to deploy GKE"
}

variable "iap_members" {
  type = list(string)
  description = "List of groups, members, service-accounts that will be given access to gke-bastion. Example [\"user:admin@mycompany.com\"]"
  default = []
}