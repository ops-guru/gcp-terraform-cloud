/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

output "name" {
  description = "Cluster name"
  value       = var.name
}

output "type" {
  description = "Cluster type (regional / zonal)"
  value       = var.regional ? "regional" : "zonal"
}

output "region" {
  description = "Cluster region"
  value       = var.region
}

output "node_locations" {
  description = "List of zones in which the cluster resides"
  value       = google_container_cluster.primary.node_locations
}

output "endpoint" {
  sensitive   = true
  description = "Cluster endpoint"
  value       = var.enable_private_endpoint ? google_container_cluster.primary.private_cluster_config.0.private_endpoint : google_container_cluster.primary.endpoint
  depends_on = [
    /* Nominally, the endpoint is populated as soon as it is known to Terraform.
    * However, the cluster may not be in a usable state yet.  Therefore any
    * resources dependent on the cluster being up will fail to deploy.  With
    * this explicit dependency, dependent resources can wait for the cluster
    * to be up.
    */
    google_container_cluster.primary,
    google_container_node_pool.pools,
  ]
}

output "min_master_version" {
  description = "Minimum master kubernetes version"
  value       = google_container_cluster.primary.min_master_version
}

output "logging_service" {
  description = "Logging service used"
  value       = google_container_cluster.primary.logging_service
}

output "monitoring_service" {
  description = "Monitoring service used"
  value       = google_container_cluster.primary.monitoring_service
}

output "master_authorized_networks_config" {
  description = "Networks from which access to master is permitted"
  value       = var.master_authorized_networks_config
}

output "master_version" {
  description = "Current master kubernetes version"
  value       = google_container_cluster.primary.master_version
}

output "ca_certificate" {
  sensitive   = true
  description = "Cluster ca certificate (base64 encoded)"
  value       = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
}

output "network_policy_enabled" {
  description = "Whether network policy enabled"
  value       = ! google_container_cluster.primary.addons_config.0.network_policy_config.0.disabled
}

output "http_load_balancing_enabled" {
  description = "Whether http load balancing enabled"
  value       = ! google_container_cluster.primary.addons_config.0.http_load_balancing.0.disabled
}

output "horizontal_pod_autoscaling_enabled" {
  description = "Whether horizontal pod autoscaling enabled"
  value       = ! google_container_cluster.primary.addons_config.0.horizontal_pod_autoscaling.0.disabled
}

output "kubernetes_dashboard_enabled" {
  description = "Whether kubernetes dashboard enabled"
  value       = ! google_container_cluster.primary.addons_config.0.kubernetes_dashboard.0.disabled
}

output "node_pools_names" {
  description = "List of node pools names"
  value       = concat(google_container_node_pool.pools.*.name, [""])
}

output "node_pools_versions" {
  description = "List of node pools versions"
  value       = concat(google_container_node_pool.pools.*.version, [""])
}

output "service_account" {
  description = "The service account to default running nodes as if not overridden in `node_pools`."
  value       = var.service_account
}

output "istio_enabled" {
  description = "Whether Istio is enabled"
  value       = ! (google_container_cluster.primary.addons_config.0.istio_config != null && length(google_container_cluster.primary.addons_config.0.istio_config) == 1 ? google_container_cluster.primary.addons_config.0.istio_config.0.disabled : false)
}

output "cloudrun_enabled" {
  description = "Whether CloudRun enabled"
  value       = var.cloudrun
}

output "pod_security_policy_enabled" {
  description = "Whether pod security policy is enabled"
  value       = google_container_cluster.primary.pod_security_policy_config != null && length(google_container_cluster.primary.pod_security_policy_config) == 1 ? google_container_cluster.primary.pod_security_policy_config.0.enabled : false
}

output "intranode_visibility_enabled" {
  description = "Whether intra-node visibility is enabled"
  value       = google_container_cluster.primary.enable_intranode_visibility
}

output "vertical_pod_autoscaling_enabled" {
  description = "Whether veritical pod autoscaling is enabled"
  value       = google_container_cluster.primary.vertical_pod_autoscaling != null && length(google_container_cluster.primary.vertical_pod_autoscaling) == 1 ? google_container_cluster.primary.vertical_pod_autoscaling.0.enabled : false
}