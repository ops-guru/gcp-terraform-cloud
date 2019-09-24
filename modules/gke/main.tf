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
data "google_container_engine_versions" "region" {
  location = local.location
  project  = var.project_id
}

data "google_container_engine_versions" "zone" {
  // Work around to prevent a lack of zone declaration from causing regional cluster creation from erroring out due to error
  //
  //     data.google_container_engine_versions.zone: Cannot determine zone: set in this resource, or set provider-level zone.
  //
  location = length(var.zones)== 0 ? data.google_compute_zones.available.names[0] : var.zones[0]
  project  = var.project_id
}

data "google_compute_zones" "available" {
  provider = google-beta

  project = var.project_id
  region  = var.region
}

resource "random_shuffle" "available_zones" {
  input        = data.google_compute_zones.available.names
  result_count = 3
}

locals {
  location = var.regional ? var.region : var.zones[0]
  cluster_cloudrun_config = var.cloudrun ? [{ disabled = false }] : []
  cluster_node_metadata_config = var.node_metadata == "UNSPECIFIED" ? [] : [{
    node_metadata = var.node_metadata
  }]
  cluster_sandbox_enabled = var.sandbox_enabled ? ["gvisor"] : []
  cluster_network_policy = var.network_policy ? [{
    enabled  = true
    provider = var.network_policy_provider
    }] : [{
    enabled  = false
    provider = null
  }]
  node_locations = var.regional ? coalescelist(compact(var.zones), sort(random_shuffle.available_zones.result)) : slice(var.zones, 1, length(var.zones))
  master_version_regional = var.kubernetes_version != "latest" ? var.kubernetes_version : data.google_container_engine_versions.region.latest_master_version
  master_version_zonal    = var.kubernetes_version != "latest" ? var.kubernetes_version : data.google_container_engine_versions.zone.latest_master_version
  master_version = var.regional ? local.master_version_regional : local.master_version_zonal
  cluster_workload_identity_config = var.identity_namespace == "" ? [] : [{
    identity_namespace = var.identity_namespace
  }]
  cluster_authenticator_security_group = var.authenticator_security_group == null ? [] : [{
    security_group = var.authenticator_security_group
  }]
}

resource "google_container_cluster" "primary" {
  provider = google-beta

  name            = var.name
  description     = var.name
  project         = var.project_id
  resource_labels = var.cluster_resource_labels

  location = var.region
  cluster_ipv4_cidr = var.cluster_ipv4_cidr
  #network = data.terraform_remote_state.infra-host-project.outputs.network_self_link
  network = var.network

  dynamic "network_policy" {
    for_each = local.cluster_network_policy

    content {
      enabled  = network_policy.value.enabled
      provider = network_policy.value.provider
    }
  }

  #subnetwork = data.terraform_remote_state.infra-host-project.outputs.subnets_self_links[1]
  subnetwork = var.subnetwork

  logging_service    = var.logging_service
  monitoring_service = var.monitoring_service
  min_master_version = local.master_version

  enable_binary_authorization = var.enable_binary_authorization
  enable_intranode_visibility = var.enable_intranode_visibility
  default_max_pods_per_node   = var.default_max_pods_per_node

  vertical_pod_autoscaling {
    enabled = var.enable_vertical_pod_autoscaling
  }

  dynamic "pod_security_policy_config" {
    for_each = var.pod_security_policy_config
    content {
      enabled = pod_security_policy_config.value.enabled
    }
  }

  dynamic "resource_usage_export_config" {
    for_each = var.resource_usage_export_dataset_id != "" ? [var.resource_usage_export_dataset_id] : []
    content {
      enable_network_egress_metering = true
      bigquery_destination {
        dataset_id = resource_usage_export_config.value
      }
    }
  }
  dynamic "master_authorized_networks_config" {
    for_each = var.master_authorized_networks_config
    content {
      dynamic "cidr_blocks" {
        for_each = master_authorized_networks_config.value.cidr_blocks
        content {
          cidr_block   = lookup(cidr_blocks.value, "cidr_block", "")
          display_name = lookup(cidr_blocks.value, "display_name", "")
        }
      }
    }
  }

  master_auth {
    username = var.basic_auth_username
    password = var.basic_auth_password

    client_certificate_config {
      issue_client_certificate = var.issue_client_certificate
    }
  }

  addons_config {
    http_load_balancing {
      disabled = ! var.http_load_balancing
    }

    horizontal_pod_autoscaling {
      disabled = ! var.horizontal_pod_autoscaling
    }

    kubernetes_dashboard {
      disabled = ! var.kubernetes_dashboard
    }

    network_policy_config {
      disabled = ! var.network_policy
    }

    istio_config {
      disabled = ! var.istio
    }

    dynamic "cloudrun_config" {
      for_each = local.cluster_cloudrun_config

      content {
        disabled = cloudrun_config.value.disabled
      }
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.ip_range_pods
    services_secondary_range_name = var.ip_range_services
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = var.maintenance_start_time
    }
  }

  lifecycle {
    ignore_changes = [node_pool, initial_node_count]
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  node_pool {
    name               = "default-pool"
    initial_node_count = var.initial_node_count

    node_config {
      service_account = var.service_account

      dynamic "workload_metadata_config" {
        for_each = local.cluster_node_metadata_config

        content {
          node_metadata = workload_metadata_config.value.node_metadata
        }
      }

      dynamic "sandbox_config" {
        for_each = local.cluster_sandbox_enabled

        content {
          sandbox_type = sandbox_config.value
        }
      }
    }
  }

  private_cluster_config {
    enable_private_endpoint = var.enable_private_endpoint
    enable_private_nodes    = var.enable_private_nodes
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  remove_default_node_pool = var.remove_default_node_pool

  dynamic "database_encryption" {
    for_each = var.database_encryption

    content {
      key_name = database_encryption.value.key_name
      state    = database_encryption.value.state
    }
  }

  dynamic "workload_identity_config" {
    for_each = local.cluster_workload_identity_config

    content {
      identity_namespace = workload_identity_config.value.identity_namespace
    }
  }

  dynamic "authenticator_groups_config" {
    for_each = local.cluster_authenticator_security_group
    content {
      security_group = authenticator_groups_config.value.security_group
    }
  }
}

/******************************************
  Create Container Cluster node pools
 *****************************************/
resource "google_container_node_pool" "pools" {
  provider = google-beta
  count    = length(var.node_pools)
  name     = var.node_pools[count.index]["name"]
  #project  = data.terraform_remote_state.infra-service-project.outputs.project_id
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.primary.name
  initial_node_count = lookup(
    var.node_pools[count.index],
    "initial_node_count",
    lookup(var.node_pools[count.index], "min_count", 1),
  )
  max_pods_per_node = lookup(var.node_pools[count.index], "max_pods_per_node", null)

  node_count = lookup(var.node_pools[count.index], "autoscaling", true) ? null : lookup(var.node_pools[count.index], "min_count", 1)

  dynamic "autoscaling" {
    for_each = lookup(var.node_pools[count.index], "autoscaling", true) ? [var.node_pools[count.index]] : []
    content {
      min_node_count = lookup(autoscaling.value, "min_count", 1)
      max_node_count = lookup(autoscaling.value, "max_count", 100)
    }
  }

  management {
    auto_repair  = lookup(var.node_pools[count.index], "auto_repair", true)
    auto_upgrade = lookup(var.node_pools[count.index], "auto_upgrade", true)
  }

  node_config {
    image_type   = lookup(var.node_pools[count.index], "image_type", "COS")
    machine_type = lookup(var.node_pools[count.index], "machine_type", "n1-standard-2")
    labels = merge(
      {
        "cluster_name" = var.name
      },
      {
        "node_pool" = var.node_pools[count.index]["name"]
      },
      var.node_pools_labels["all"],
      var.node_pools_labels[var.node_pools[count.index]["name"]],
    )
    metadata = merge(
      {
        "cluster_name" = var.name
      },
      {
        "node_pool" = var.node_pools[count.index]["name"]
      },
      var.node_pools_metadata["all"],
      var.node_pools_metadata[var.node_pools[count.index]["name"]],
      {
        "disable-legacy-endpoints" = true
      },
    )
    dynamic "taint" {
      for_each = concat(
        var.node_pools_taints["all"],
        var.node_pools_taints[var.node_pools[count.index]["name"]],
      )
      content {
        effect = taint.value.effect
        key    = taint.value.key
        value  = taint.value.value
      }
    }
    tags = concat(
      ["gke-${var.name}"],
      ["gke-${var.name}-${var.node_pools[count.index]["name"]}"],
      var.node_pools_tags["all"],
      var.node_pools_tags[var.node_pools[count.index]["name"]],
    )

    disk_size_gb = lookup(var.node_pools[count.index], "disk_size_gb", 100)
    disk_type    = lookup(var.node_pools[count.index], "disk_type", "pd-standard")
    service_account = var.service_account
    preemptible = lookup(var.node_pools[count.index], "preemptible", false)

    oauth_scopes = concat(
      var.node_pools_oauth_scopes["all"],
      var.node_pools_oauth_scopes[var.node_pools[count.index]["name"]],
    )

    guest_accelerator = [
      for guest_accelerator in lookup(var.node_pools[count.index], "accelerator_count", 0) > 0 ? [{
        type  = lookup(var.node_pools[count.index], "accelerator_type", "")
        count = lookup(var.node_pools[count.index], "accelerator_count", 0)
        }] : [] : {
        type  = guest_accelerator["type"]
        count = guest_accelerator["count"]
      }
    ]

    dynamic "workload_metadata_config" {
      for_each = local.cluster_node_metadata_config

      content {
        node_metadata = workload_metadata_config.value.node_metadata
      }
    }
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}