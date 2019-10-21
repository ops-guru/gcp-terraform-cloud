module "gke" {
  source = "../modules/gke"
  name = "application-cluster-${var.environment}"
  project_id = data.terraform_remote_state.infra-host-project.outputs.project_id
  network = data.terraform_remote_state.infra-host-project.outputs.network_self_link
  service_account = data.terraform_remote_state.infra-host-project.outputs.service-accounts.gke-cluster
  ip_range_pods = "pods"
  ip_range_services = "services"
  subnetwork = data.terraform_remote_state.infra-host-project.outputs.subnets_self_links[1]
  master_ipv4_cidr_block = "10.0.1.0/28"
  region = var.region
  identity_namespace = "${data.terraform_remote_state.infra-host-project.outputs.project_id}.svc.id.goog"
  master_authorized_networks_config = [{
    cidr_blocks = [{
      cidr_block = data.terraform_remote_state.infra-host-project.outputs.subnets_ips[0]
      display_name = "General Subnet"
    }]
  }]
}

module "gke-bastion" {
  source = "../modules/gke-bastion"
  name = "gke-bastion-${var.environment}"
  project_id = data.terraform_remote_state.infra-host-project.outputs.project_id
  zone = "${var.region}-b"
  service_account = data.terraform_remote_state.infra-host-project.outputs.service-accounts.gke-bastion
  subnetwork = data.terraform_remote_state.infra-host-project.outputs.subnets_self_links[0]
  iap_members = var.iap_members
}