variable "clusters" {
  type = map(object({
    cluster_name = string
    cluster_location = string
    remove_default_node_pool =bool
    initial_node_count = number
    enable_cluster_autoscaling = bool
    enable_master_global_access_config =bool
    enable_private_endpoint = bool
    enable_private_nodes = bool 
    master_ipv4_cidr_block = string
    authorized_networks = map(object({
            cidr_block = string
            display_name = string
    }))
    cluster_ipv4_cidr_block  = string
    services_ipv4_cidr_block = string
    networking_mode =string
    vpc_id = string
    subnet_name = string
    release_channel = string
    enable_network_policy = bool
  }))
}
variable "node_pools" {
  type = map(object({
    node_locations = list(string)
    node_count = number
    node_config = object({
        image_type = string
        machine_type =string
        disk_size_gb = number
        service_account = string
        disk_type = string 
        oauth_scopes = list(string)
    })
    auto_repair  = bool
    auto_upgrade = bool
    max_surge = number
    max_unavailable =number
  }))
}
