resource "google_bigquery_dataset" "public" {
  dataset_id                  = var.id
  friendly_name               = var.name
  location                    = var.location
  project = var.project_id
  access {
   user_by_email = var.user_by_email 
   role = var.role
  }
}