variable "credentials" {
  description = "Path to service account credentials"
}

variable "environment" {
  description = "Environment. Valid values are dev, stg, and prd"
}

variable "terraform_organization" {
  description = "Terraform Organization that holds all workspaces"
}

variable "superadmins" {
  description = "List of superadmin groups/members in format [\"group:non-admin1@mycompanydomain.com\", \"user:username@mycompanydomain.com\"]"
  type = list(string)
  default = []
}

variable "viewers" {
  description = "List of viewers groups/members in format [\"group:admin@mycompanydomain.com\", \"user:username@mycompanydomain.com\"]"
  type = list(string)
  default = []
}

variable "secops" {
  description = "List of security operators groups/members in format [\"group:qa@mycompanydomain.com\", \"user:username@mycompanydomain.com\"]"
  type = list(string)
  default = []
}