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

module "vpc1" {
  source            = "git@github.com:ops-guru/terraform-google-network.git?ref=1cdd791960b42308d8bb1bea0b40aa2fc1badb90"
  project_id        = module.host-vpc-project.project_id
  network_name      = "vpc-${var.environment}"
  routing_mode      = "GLOBAL"
  shared_vpc_host   = "true"
  subnets           = var.subnets
  secondary_ranges  = var.secondary_ranges
}

resource "google_compute_router" "router" {
  name    = "cloud-nat-router-${var.environment}"
  network = module.vpc1.network_self_link
  project = module.host-vpc-project.project_id
  region  = var.cloud_nat_region
}

module "cloud-nat" {
  source     = "git@github.com:ops-guru/terraform-google-cloud-nat.git?ref=81aa147d1f493ec8394a66537726a4b648d5d460"
  project_id = module.host-vpc-project.project_id
  region     = var.cloud_nat_region
  router     = google_compute_router.router.name
}

module "service-project" {
  source            = "git@github.com:ops-guru/terraform-google-project-factory.git?ref=8837b4b6d825be74b1351165671a9e88202af0cd"
  name              = "service-project-${var.environment}"
  random_project_id = true
  org_id            = var.org_id
  billing_account   = var.billing_account_id
  folder_id         = var.parent_folder == "" ? google_folder.org[0].id : google_folder.folder[0].id
  credentials_path  = local_file.creds.filename
  shared_vpc        = module.host-vpc-project.project_id
  default_service_account = "keep"

  shared_vpc_subnets = [
    "projects/${module.host-vpc-project.project_id}/regions/${module.vpc1.subnets_regions[0]}/subnetworks/${module.vpc1.subnets_names[0]}",
    "projects/${module.host-vpc-project.project_id}/regions/${module.vpc1.subnets_regions[1]}/subnetworks/${module.vpc1.subnets_names[1]}",
    "projects/${module.host-vpc-project.project_id}/regions/${module.vpc1.subnets_regions[2]}/subnetworks/${module.vpc1.subnets_names[2]}",
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