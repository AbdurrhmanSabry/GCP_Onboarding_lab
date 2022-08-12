resource "google_service_account" "service_account" {
  account_id   = var.id
  display_name = var.name
  project = var.project_id
}
