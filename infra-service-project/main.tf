resource "local_file" "creds" {
  filename = "${path.module}/creds.json"
  sensitive_content = var.credentials
}

module "service-project" {
  source            = "git@github.com:ops-guru/terraform-google-project-factory.git?ref=8837b4b6d825be74b1351165671a9e88202af0cd"
  name              = "service-project-${var.environment}"
  random_project_id = true
  org_id            = var.org_id
  billing_account   = var.billing_account_id
  folder_id         = data.terraform_remote_state.infra-host-project.outputs.folder_id
  credentials_path  = local_file.creds.filename
  shared_vpc        = data.terraform_remote_state.infra-host-project.outputs.project_id
  default_service_account = "keep"

  shared_vpc_subnets = [
    "projects/${data.terraform_remote_state.infra-host-project.outputs.project_id}/regions/${data.terraform_remote_state.infra-host-project.outputs.subnets_regions[0]}/subnetworks/${data.terraform_remote_state.infra-host-project.outputs.subnets_names[0]}",
    "projects/${data.terraform_remote_state.infra-host-project.outputs.project_id}/regions/${data.terraform_remote_state.infra-host-project.outputs.subnets_regions[1]}/subnetworks/${data.terraform_remote_state.infra-host-project.outputs.subnets_names[1]}",
    "projects/${data.terraform_remote_state.infra-host-project.outputs.project_id}/regions/${data.terraform_remote_state.infra-host-project.outputs.subnets_regions[2]}/subnetworks/${data.terraform_remote_state.infra-host-project.outputs.subnets_names[2]}",
  ]

  activate_apis = [
    "appengine.googleapis.com",
    "cloudapis.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "sourcerepo.googleapis.com",
    "servicenetworking.googleapis.com",
  ]
}

resource "google_service_account" "accounts" {
  count = length(var.service_accounts)
  project = module.service-project.project_id
  account_id = "${var.service_accounts[count.index]}-${var.environment}"
  display_name = "${var.service_accounts[count.index]} for ${var.environment} environment"
}

locals {
  formatted_output_sa = {for sa in var.service_accounts : sa =>
    [
      for sa_email in google_service_account.accounts.*.email : sa_email if length(regexall(sa, sa_email)) > 0
    ][0]
  }
}