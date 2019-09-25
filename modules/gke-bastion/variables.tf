variable "project_id" {
  type = string
  description = "Project ID"
}

variable "subnetwork" {
  type = string
  description = "Subnetwork self link"
}

variable "name" {
  type = string
  description = "Bastion instance name"
}

variable "zone" {
  type = string
  description = "Instance zone"
}

variable "service_account" {
  type = string
  description = "Service Account to be applied to gke-bastion"
}

variable "machine_type" {
  type = string
  description = "Machine type"
  default = "n1-standard-1"
}

variable "iap_members" {
  type = list(string)
  description = "List of groups, members, service-accounts that will be given access to gke-bastion. Example [\"user:admin@mycompany.com\"]"
  default = []
}