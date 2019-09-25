output "instance_name" {
  description = "Instance Name"
  value = google_compute_instance.gke_bastion.name
}

output "instance_self_link" {
  description = "Instance URI"
  value = google_compute_instance.gke_bastion.self_link
}

output "instance_zone" {
  description = "Instance zone"
  value = google_compute_instance.gke_bastion.zone
}

output "service_account" {
  description = "Instance Service Account"
  value = google_compute_instance.gke_bastion.service_account
}