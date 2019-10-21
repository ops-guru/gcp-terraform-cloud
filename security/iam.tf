locals {
  gke_bastion = [
    "roles/container.admin",
    "roles/storage.objectCreator",
    "roles/storage.objectViewer",
  ]
  gke_cluster = [
    "roles/storage.objectCreator",
    "roles/storage.objectViewer",
  ]
}

resource "google_project_iam_member" "gke_bastion" {
  count = length(local.gke_bastion)
  project = data.terraform_remote_state.infra-host-project.outputs.project_id
  member = "serviceAccount:${data.terraform_remote_state.infra-host-project.outputs.service-accounts.gke-bastion}"
  role = local.gke_bastion[count.index]
}

resource "google_project_iam_member" "gke_cluster" {
  count = length(local.gke_cluster)
  project = data.terraform_remote_state.infra-host-project.outputs.project_id
  member = "serviceAccount:${data.terraform_remote_state.infra-host-project.outputs.service-accounts.gke-cluster}"
  role = local.gke_cluster[count.index]
}

resource "google_folder_iam_member" "superadmins" {
  count = length(var.superadmins)
  folder = data.terraform_remote_state.infra-host-project.outputs.folder_id
  role = "roles/owner"
  member = var.superadmins[count.index]
}

resource "google_folder_iam_member" "viewers" {
  count = length(var.viewers)
  folder = data.terraform_remote_state.infra-host-project.outputs.folder_id
  role = "roles/viewer"
  member = var.superadmins[count.index]
}

locals {
  secop_roles = [
    "roles/compute.networkViewer",
    "roles/compute.securityAdmin",
    "roles/compute.osAdminLogin",
    "roles/compute.viewer",
    "roles/iam.securityReviewer",
    "roles/iam.securityAdmin",
    "roles/container.viewer",
  ]
  secops_bindings = setproduct(var.secops, local.secop_roles)
}

resource "google_folder_iam_member" "secops" {
  count = length(local.secops_bindings)
  folder = data.terraform_remote_state.infra-host-project.outputs.folder_id
  member = local.secops_bindings[count.index][0]
  role = local.secops_bindings[count.index][1]
}