workspace = "infra-host-project-stg"
credentials = "../credentials.json"
environment = "stg"

subnets = [
  {
    subnet_name           = "general"
    subnet_ip             = "10.0.0.0/24"
    subnet_region         = "us-central1"
    subnet_private_access = "true"
    subnet_flow_logs      = "true"
  },
  {
    subnet_name           = "gke"
    subnet_ip             = "10.15.0.0/20"
    subnet_region         = "us-central1"
    subnet_private_access = "true"
    subnet_flow_logs      = "true"
  },
  {
    subnet_name           = "data"
    subnet_ip             = "10.1.0.0/16"
    subnet_region         = "us-central1"
    subnet_private_access = "true"
    subnet_flow_logs      = "true"
  }
]

secondary_ranges = {
  general = []
  gke = [
    {
      range_name = "pods"
      ip_cidr_range = "10.16.0.0/16"
    },
    {
      range_name = "services"
      ip_cidr_range = "10.17.0.0/22"
    }
  ]
  data = []
}

cloud_nat_region = "us-central1"