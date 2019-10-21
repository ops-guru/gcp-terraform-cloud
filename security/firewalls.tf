resource "google_compute_firewall" "gke-bastion" {
  name = "gke-bastion-${var.environment}"
  network = data.terraform_remote_state.infra-host-project.outputs.network_name
  project = data.terraform_remote_state.infra-host-project.outputs.project_id
  target_service_accounts = [data.terraform_remote_state.infra-host-project.outputs.service-accounts.gke-bastion]
  allow {
    protocol = "tcp"
    ports = [22]
  }
}

resource "google_compute_firewall" "gke-cluster" {
  name = "gke-cluster-${var.environment}"
  network = data.terraform_remote_state.infra-host-project.outputs.network_name
  project = data.terraform_remote_state.infra-host-project.outputs.project_id
  target_service_accounts = [data.terraform_remote_state.infra-host-project.outputs.service-accounts.gke-cluster]
  allow {
    protocol = "tcp"
    ports = [80, 443]
  }
}

resource "google_compute_firewall" "mysql" {
  name = "mysql-${var.environment}"
  network = data.terraform_remote_state.infra-host-project.outputs.network_name
  project = data.terraform_remote_state.infra-host-project.outputs.project_id
  target_service_accounts = [data.terraform_remote_state.infra-host-project.outputs.service-accounts.mysql]
  allow {
    protocol = "tcp"
    ports = [3306]
  }
}

resource "google_compute_firewall" "kafka" {
  name = "kafka-${var.environment}"
  network = data.terraform_remote_state.infra-host-project.outputs.network_name
  project = data.terraform_remote_state.infra-host-project.outputs.project_id
  target_service_accounts = [data.terraform_remote_state.infra-host-project.outputs.service-accounts.kafka]
  allow {
    protocol = "tcp"
    ports = [9092, 9093, 9393, 9394, 24042]
  }
}