provider "google" {
  version = "~> 2.14.0"
  credentials = var.credentials
}

provider "google-beta" {
  version = "~> 2.14.0"
  credentials = var.credentials
}