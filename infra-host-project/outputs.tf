output "project_id" {
  description = "Host project ID"
  value = module.host-vpc-project.project_id
}

output "folder_id" {
  description = "Environment folder id"
  value = var.parent_folder == "" ? google_folder.org[0].id : google_folder.folder[0].id
}

output "network_self_link" {
  description = "The URL of the VPC"
  value = module.vpc1.network_self_link
}

output "network_name" {
  description = "The name of the VPC"
  value = module.vpc1.network_name
}

output "subnets_ips" {
  description = "The IPs and CIDRs of the subnets"
  value = module.vpc1.subnets_ips
}

output "subnets_names" {
  description = "The names of the subnets being created"
  value = module.vpc1.subnets_names
}

output "subnets_regions" {
  description = "The regions where the subnets will be created"
  value = module.vpc1.subnets_regions
}

output "subnets_self_links" {
  description = "The subnets URLs"
  value = module.vpc1.subnets_self_links
}

output "subnets_secondary_ranges" {
  description = "The subnets secondary ranges"
  value = module.vpc1.subnets_secondary_ranges
}

output "master_ipv4_cidr_block" {
  description = "Master IPv4 CIDR block for GKE"
  value = "10.17.5.0/28"
}

output "nat_name" {
  description = "Name of the Cloud NAT"
  value = module.cloud-nat.name
}

output "nat_ip_allocate_option" {
  description = "NAT IP allocation mode"
  value = module.cloud-nat.nat_ip_allocate_option
}

output "cloud_nat_region" {
  description = "Cloud NAT region"
  value = module.cloud-nat.region
}

output "router_name" {
  description = "Cloud NAT router name"
  value = module.cloud-nat.router_name
}