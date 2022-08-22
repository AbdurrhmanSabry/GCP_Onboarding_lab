resource "google_compute_network" "vpc" {
  for_each = var.vpcs
  project = each.value.project_id
  name                    = each.value.vpc_name
  auto_create_subnetworks = each.value.auto_create_subnetworks
  mtu                     = each.value.mtu
  routing_mode = each.value.routing_mode
}

