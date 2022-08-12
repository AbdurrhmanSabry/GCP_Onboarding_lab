# resource "google_compute_router" "router" {
#   name    = "my-router"
#   region  = var.subnet_region
#   network = google_compute_network.vpc.id

#   bgp {
#     asn = 64514
#   }
# }

# resource "google_compute_router_nat" "nat" {
#   name                               = "my-nat"
#   router                             = google_compute_router.router.name
#   region                             = google_compute_router.router.region
#   nat_ip_allocate_option             = "AUTO_ONLY"
#   source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
#   subnetwork  {
#     name = google_compute_subnetwork.subnetwork.name
#     source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
#   } 
# }