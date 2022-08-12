resource "google_compute_subnetwork" "subnetwork" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  region        = var.subnet_region
  project = var.project_id
  private_ip_google_access = true
  network       = google_compute_network.vpc.id
}