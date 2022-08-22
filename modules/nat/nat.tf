resource "google_compute_router_nat" "nat" {
  for_each = {
    for nat in local.routers_nats : "${nat.nat_key}-${nat.router_key}" => nat
  }
  name                               = each.value.nat_name
  router                             = each.value.router_name
  region                             = each.value.subnet_region
  nat_ip_allocate_option             = each.value.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = each.value.source_subnetwork_ip_ranges_to_nat
  subnetwork  {
    name = each.value.subnet_name
    source_ip_ranges_to_nat = each.value.source_ip_ranges_to_nat
  } 
}

locals {
  # setproduct works with sets and lists, but the variables are both maps
  # so convert them first.

  routers = [
    for key, router in var.routers : {
      key = key 
      vpc_id = router.vpc_id
      subnet_region = router.subnet_region
      subnet_name = router.subnet_name
      bgp_asn = router.bgp_asn
    }
  ]

  nats = [
    for key, nat in var.nat_details : {
      key = key
      project_id = nat.project_id
      source_ip_ranges_to_nat = nat.source_ip_ranges_to_nat
      nat_name = nat.nat_name
      nat_ip_allocate_option = nat.nat_ip_allocate_option
      source_subnetwork_ip_ranges_to_nat = nat.source_subnetwork_ip_ranges_to_nat
    }
  ]
  # in pair, element zero is a router and element one is a nat,
  # in all unique combinations.

  routers_nats  = [
    for pair in setproduct(local.routers , local.nats) : {
      # The project_id is derived from the corresponding nat.
      router_key = pair[0].key 
      project_id = pair[1].project_id
      nat_key = pair[1].key
      source_ip_ranges_to_nat =pair[1].source_ip_ranges_to_nat
      nat_name = pair[1].nat_name
      nat_ip_allocate_option = pair[1].nat_ip_allocate_option
      source_subnetwork_ip_ranges_to_nat =pair[1].source_subnetwork_ip_ranges_to_nat
      subnet_region = pair[0].subnet_region
      subnet_name = pair[0].subnet_name
      router_name = google_compute_router.router[pair[0].key].name
    }
  ]
}