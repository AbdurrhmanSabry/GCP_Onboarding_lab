resource "google_container_cluster" "primary" {
  name     = var.cluster-name
  location = "${var.region}-${var.zone_one}"

  remove_default_node_pool = true
  initial_node_count       = 1
  cluster_autoscaling {
    enabled = false
  }
  private_cluster_config  {
    master_global_access_config {
      enabled = false
    }
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = var.authorized-network-cidr
      display_name = "authorized-network"
    }
  }
  ip_allocation_policy {
    cluster_ipv4_cidr_block = var.pods_ipv4_cidr_block
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }
  networking_mode = "VPC_NATIVE"
  network = var.vpc_id
  subnetwork = var.subnet_name
  release_channel {
      channel = "STABLE"
  }
  addons_config {
    network_policy_config {
        disabled = false
      }
  }
  network_policy {
    enabled = "true"
  }
  
}

