locals {
  # setproduct works with sets and lists, but the variables are both maps
  # so convert them first.

  networks = [
    for key, network in var.vpcs : {
      key = key 
      vpc_name = network.vpc_name
      project_id = network.project_id
    }
  ]

  subnets = [
    for key, subnet in var.subnets : {
      key = key
    #  subnet_name = subnet.subnet_name
      subnet_cidr = subnet.subnet_cidr
      subnet_region = subnet.subnet_region
      private_ip_google_access  = subnet.private_ip_google_access
    }
  ]
  # in pair, element zero is a network and element one is a subnet,
  # in all unique combinations.

  network_subnets = [
    for pair in setproduct(local.networks , local.subnets) : {
      # The project_id is derived from the corresponding network.
      network_key = pair[0].key 
      vpc_name = pair[0].vpc_name
      project_id = pair[0].project_id
      subnet_key = pair[1].key
    #  subnet_name = pair[1].subnet_name
      subnet_cidr = pair[1].subnet_cidr
      subnet_region = pair[1].subnet_region
      private_ip_google_access  = pair[1].private_ip_google_access
      vpc_id = google_compute_network.vpc[pair[0].key].id
    }
  ]
}
resource "google_compute_subnetwork" "subnetwork" {
  # local.network_subnets is a list, so project it into a map
  # where each key is unique. Combine the network and subnet keys to
  # produce a single unique key per instance.
  for_each = {
    for subnet in local.network_subnets : "${subnet.network_key}-${subnet.subnet_key}" => subnet
  }
  name          = "${each.value.subnet_key}-${each.value.vpc_name}"
  ip_cidr_range = each.value.subnet_cidr
  region        = each.value.subnet_region
  project = each.value.project_id
  private_ip_google_access = each.value.private_ip_google_access
  network       = each.value.vpc_id
}