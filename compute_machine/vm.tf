resource "google_compute_instance" "vm" {
  name         = var.machine_name
  machine_type = var.machine_type
  zone         = "${var.region}-${var.zone}"
  project = var.project_id 
  tags = ["vm"]  
  boot_disk {
    initialize_params {
      image = var.os_image
      size = var.boot_disk_size
    }
  }

  metadata_startup_script = var.startup-script

  network_interface {
    network = var.vpc_name
    subnetwork = var.subnet_name
  }
  service_account {
    email = var.sa-email
    scopes = ["cloud-platform"]
  }
}