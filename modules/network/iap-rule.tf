resource "google_compute_firewall" "allow-iap" {
  for_each = google_compute_network.vpc
  project     = each.value.project
  name        = "allow-iap-${each.value.name}"
  network     = each.value.name
  description = "Creates firewall rule allowing access from iap range"
  source_ranges = ["35.235.240.0/20"]
  priority = 100
  direction  = "INGRESS"
   allow {
    protocol  = "all"
  }
}