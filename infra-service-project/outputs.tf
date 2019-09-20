output "project_id" {
  description = "Service projec ID"
  value = module.service-project.project_id
}

output "service-accounts" {
  description = "List of service account emails"
  value = google_service_account.accounts.*.email
}