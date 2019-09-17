resource "google_folder" "org" {
  count = var.parent_folder == "" ? 1 : 0
  display_name = upper(var.environment)
  parent = "organizations/${var.org_id}"
}

resource "google_folder" "folder" {
  count = var.parent_folder != "" ? 1 : 0
  display_name = upper(var.environment)
  parent = "folders/${var.parent_folder}"
}

resource "local_file" "creds" {
  filename = "${path.module}/creds.json"
  sensitive_content = var.credentials
}

module "host-vpc-project" {
  source = "git@github.com:ops-guru/terraform-google-project-factory.git?ref=8837b4b6d825be74b1351165671a9e88202af0cd"
  name = "host-vpc-${var.environment}"
  random_project_id = true
  org_id = var.org_id
  billing_account = var.billing_account_id
  folder_id = var.parent_folder == "" ? google_folder.org[0].id : google_folder.folder[0].id
  credentials_path  = local_file.creds.filename
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
  default_service_account = "keep"
}