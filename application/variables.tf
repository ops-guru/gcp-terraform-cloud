variable "credentials" {
  description = "Path to service account credentials"
}

variable "environment" {
  description = "Environment. Valid values are dev, stg, and prd"
}

variable "terraform_organization" {
  description = "Terraform Organization that holds all workspaces"
}

variable "region" {
  description = "Region where to deploy GKE"
}

variable "node_pools" {
  description = "List of node pools"
  type = list(object({
    name = string
    machine_type = string
    min_count = number
    max_count = number
    disk_size_gb = number
    auto_upgrade = bool
    auto_repair = bool
  }))
  default = [
    {
      name         = "microservices"
      machine_type = "n1-standard-2"
      min_count    = 1
      max_count    = 3
      disk_size_gb = "100"
      auto_upgrade = true
      auto_repair  = true
    }
  ]
}

variable "node_pools_labels" {
  type        = map(map(string))
  description = "Map of maps containing node labels by node-pool name"

  default = {
    all               = {}
    microservices = {}
  }
}

variable "node_pools_oauth_scopes" {
  description = "Node Pools oauth scopes"
  type        = map(any)
  default = {
    all = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    microservices = []
  }
}

variable "node_pools_metadata" {
  description = "Node pools metadata"
  type        = map(any)
  default     = {
    all           = {}
    microservices = {}
  }
}

variable "node_pools_lables_microservices" {
  description = "Node pools labels"
  type        = map(string)
  default     = {}
}

variable "node_pools_taints" {
  description = "Node pool taints"
  type        = map(any)
  default     = {
    all           = []
    microservices = []
  }
}

variable "node_pools_tags" {
  description = "Node pools tags"
  type        = map(any)
  default     = {
    all           = []
    microservices = []
  }
}

variable "istio" {
  description = "Enable istio"
  default = false
}

variable "cloudrun" {
  description = "Enable cloudrun"
  default = false
}

variable "resource_usage_export_dataset_id" {
  type        = string
  description = "The dataset id for which network egress metering for this cluster will be enabled. If enabled, a daemonset will be created in the cluster to meter network egress traffic."
  default     = ""
}

variable "maintenance_start_time" {
  type        = string
  description = "Time window specified for daily maintenance operations in RFC3339 format"
  default     = "05:00"
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "(Beta) The IP range in CIDR notation to use for the hosted master network"
  default     = "10.0.1.0/28"
}

variable "database_encryption" {
  description = "Application-layer Secrets Encryption settings. The object format is {state = string, key_name = string}. Valid values of state are: \"ENCRYPTED\"; \"DECRYPTED\". key_name is the name of a CloudKMS key."
  type        = list(object({ state = string, key_name = string }))
  default = [{
    state    = "DECRYPTED"
    key_name = ""
  }]
}

variable "node_metadata" {
  description = "Specifies how node metadata is exposed to the workload running on the node"
  default     = "SECURE"
  type        = string
}

variable "sandbox_enabled" {
  type        = bool
  description = "(Beta) Enable GKE Sandbox (Do not forget to set `image_type` = `COS_CONTAINERD` and `node_version` = `1.12.7-gke.17` or later to use it)."
  default     = false
}