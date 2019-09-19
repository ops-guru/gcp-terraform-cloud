data "terraform_remote_state" "infra-host-project" {
  backend = "remote"
  config = {
    organization = var.terraform_organization
    workspaces = {
      name = "infra-host-project-${var.environment}"
    }
  }
}