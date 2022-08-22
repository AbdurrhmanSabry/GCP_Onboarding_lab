resource "google_container_cluster" "primary" {
  for_each = var.clusters
  name     = each.value.cluster_name
  location = each.value.cluster_location

  remove_default_node_pool = each.value.remove_default_node_pool
  initial_node_count       = each.value.initial_node_count
  cluster_autoscaling {
    enabled = each.value.enable_cluster_autoscaling
  }
  private_cluster_config  {
    master_global_access_config {
      enabled = each.value.enable_master_global_access_config
    }
    enable_private_endpoint = each.value.enable_private_endpoint
    enable_private_nodes    = each.value.enable_private_nodes
    master_ipv4_cidr_block  = each.value.master_ipv4_cidr_block
  }
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = each.value.authorized_networks
      content {
        cidr_block = cidr_blocks.value["cidr_block"]
        display_name = cidr_blocks.value["display_name"]
      }
    }
    
  }
  ip_allocation_policy {
    cluster_ipv4_cidr_block = each.value.cluster_ipv4_cidr_block
    services_ipv4_cidr_block = each.value.services_ipv4_cidr_block
  }
  networking_mode = each.value.networking_mode
  network = each.value.vpc_id
  subnetwork = each.value.subnet_name
  release_channel {
      channel = each.value.release_channel
  }
  addons_config {
    network_policy_config {
        disabled = each.value.enable_network_policy == true ? false : true
      }
  }
  network_policy {
    enabled = each.value.enable_network_policy
  }
  
}

