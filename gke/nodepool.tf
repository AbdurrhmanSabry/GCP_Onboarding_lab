resource "google_container_node_pool" "node_pool" {
  name       = "node-pool"
  location   = "${var.region}-${var.zone_one}"
  node_locations = ["${var.region}-${var.zone_one}","${var.region}-${var.zone_two}" ]
  cluster    = google_container_cluster.primary.name
  node_count = var.node-count

  node_config {
    image_type = var.os_image
    machine_type = var.node-machine-type
    disk_size_gb = var.node_boot_disk_size
    service_account = var.service-account-email
    disk_type = var.node_boot_disk_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
    
  }
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 1
  }
  management {
    auto_repair  = true
    auto_upgrade = true
  }

}