resource "google_compute_instance" "vm" {
  for_each = var.compute_machines
  name         = each.value.machine_name
  machine_type = each.value.machine_type
  zone         =  each.value.vm_location
  project = each.value.project_id
  tags = each.value.tags
  boot_disk {
    initialize_params {
      image = each.value.os_image
      size = each.value.boot_disk_size
    }
  }
  
  
  metadata_startup_script = each.value.startup_script

  network_interface {
    network = each.value.vpc_name
    subnetwork = each.value.subnet_name
  }
  service_account {
    email = each.value.sa_email
    scopes = each.value.scopes
  }
}