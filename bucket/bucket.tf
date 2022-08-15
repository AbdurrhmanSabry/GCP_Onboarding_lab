resource "google_storage_bucket" "bucket" {
  for_each = var.buckets_info
  name          = each.value.name
  location      = each.value.location
  project = var.project_id
  storage_class = each.value.storage_class
}
