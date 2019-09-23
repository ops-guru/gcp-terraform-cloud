data "terraform_remote_state" "infra-host-project" {
  backend = "remote"
  config = {
    organization = var.terraform_organization
    workspaces = {
      name = "infra-host-project-${var.environment}"
    }
  }
}

data "terraform_remote_state" "infra-service-project" {
  backend = "remote"
  config = {
    organization = var.terraform_organization
    workspaces = {
      name = "infra-service-project-${var.environment}"
    }
  }
}