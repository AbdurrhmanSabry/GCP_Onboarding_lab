resource "google_container_node_pool" "node_pool" {
  for_each = {
    for pool in local.clusters_pools : "${pool.cluster_key}-${pool.pool_key}" => pool
  }
  name       = each.value.pool_key
  location   = each.value.cluster_location
  node_locations =  each.value.node_locations
  cluster    = each.value.cluster_name
  node_count = each.value.node_count

  node_config  {
    image_type = each.value.node_config.image_type
    machine_type = each.value.node_config.machine_type
    disk_size_gb = each.value.node_config.disk_size_gb
    service_account = each.value.node_config.service_account
    disk_type = each.value.node_config.disk_type
    oauth_scopes = each.value.node_config.oauth_scopes
    
   }
  upgrade_settings {
    max_surge       = each.value.max_surge
    max_unavailable =  each.value.max_unavailable
  }
  management {
    auto_repair  = each.value.auto_repair
    auto_upgrade = each.value.auto_upgrade
  }

}

locals {
  # setproduct works with sets and lists, but the variables are both maps
  # so convert them first.
  clusters = [
    for key, cluster in var.clusters : {
      key        = key
      cluster_name = cluster.cluster_name
      cluster_location = cluster.cluster_location
    }
  ]
  pools = [
    for key, pool in var.node_pools : {
      key    = key
      node_locations = pool.node_locations
      node_count = pool.node_count 
      node_config = pool.node_config
      auto_repair  = pool.auto_repair
      auto_upgrade = pool.auto_upgrade
      max_surge = pool.max_surge
      max_unavailable = pool.max_unavailable
    }
  ]

  clusters_pools = [
    # in pair, element zero is a cluster and element one is a pool,
    # in all unique combinations.
    for pair in setproduct(local.clusters, local.pools) : {
      cluster_key = pair[0].key
      cluster_name  = pair[0].cluster_name
      cluster_location = pair[0].cluster_location
      pool_key  = pair[1].key
      node_locations = pair[1].node_locations
      node_count = pair[1].node_count 
      node_config = pair[1].node_config
      auto_repair  = pair[1].auto_repair
      auto_upgrade = pair[1].auto_upgrade
      max_surge = pair[1].max_surge
      max_unavailable = pair[1].max_unavailable

    }
  ]
}

