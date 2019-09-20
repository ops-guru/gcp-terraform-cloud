variable "credentials" {
  description = "Path to service account credentials"
}

variable "environment" {
  description = "Environment. Valid values are dev, stg, and prd"
}

variable "org_id" {
  description = "Organization ID"
}

variable "billing_account_id" {
  description = "Billing Account ID"
}

variable "terraform_organization" {
  description = "Terraform Organization that holds all workspaces"
}

variable "service_accounts" {
  description = "List of service accounts to create"
  type = list(string)
  default = [
    "kafka",
    "rabbitmq",
    "gke-cluster",
    "gke-bastion",
    "terraform",
    "mysql",
  ]
}