resource "google_compute_firewall" "allow-iap" {
  project     = var.project_id
  name        = "allow-iap"
  network     = google_compute_network.vpc.name
  description = "Creates firewall rule allowing access from iap range"
  source_ranges = ["35.235.240.0/20"]
  priority = 100
  direction  = "INGRESS"
   allow {
    protocol  = "all"
  }
}