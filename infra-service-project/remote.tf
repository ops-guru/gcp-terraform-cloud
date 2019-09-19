data "terraform_remote_state" "infra-host-project" {
  backend = "remote"
  config = {
    organization = var.terraform_organization
    workspcases = {
      name = "infra-host-project-${var.environment}"
    }
  }
}