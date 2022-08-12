resource "google_storage_bucket" "bucket" {
  name          = var.name
  location      = var.location
  project = var.project_id
  storage_class = var.storage_class
}
