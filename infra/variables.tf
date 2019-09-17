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

variable "parent_folder" {
  description = "Parent Folder"
  default = ""
}

variable "subnets" {
  description = "Default subnets"
  type = list(map(string))
}

variable "secondary_ranges" {
  description = "Default seconday ranges"
  type = map(any)
}

variable "cloud_nat_region" {
  description = "Region where cloud nat router will be deployed. Should be the same regions as your subnetworks"
}