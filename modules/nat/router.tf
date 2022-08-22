resource "google_compute_router" "router" {
  for_each =  var.routers
  name    = "router-${each.value.subnet_name}"
  region  = each.value.subnet_region
  network = each.value.vpc_id

  bgp {
    asn = each.value.bgp_asn
  }
}