resource "google_service_account" "service_account" {
  count  = length(var.ids) 
  account_id   = var.ids[count.index]
  display_name = var.names[count.index]
  project = var.project_id
}