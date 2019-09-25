data "template_file" "install_script" {
  template = file("${path.module}/templates/startup.sh.tpl")
}

resource "google_compute_instance" "gke_bastion" {
  machine_type = var.machine_type
  name = var.name
  project = var.project_id
  zone = var.zone

  network_interface {
    subnetwork = var.subnetwork
  }

  service_account {
    email = var.service_account
    scopes = ["userinfo-email", "cloud-platform"]
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  metadata_startup_script = data.template_file.install_script.rendered
}

resource "google_iap_tunnel_instance_iam_binding" "main" {
  provider = "google-beta"
  project = var.project_id
  instance = google_compute_instance.gke_bastion.name
  zone = var.zone
  role = "roles/iap.tunnelResourceAccessor"
  members = var.iap_members
}