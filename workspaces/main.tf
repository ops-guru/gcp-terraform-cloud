resource "tfe_workspace" "ws" {
  name = "infra-devs"
  organization = var.terraform_cloud_org
  vcs_repo {
    identifier = "ops-guru/gcp-terraform-cloud"
    oauth_token_id = var.oauth_token_id
  }
}