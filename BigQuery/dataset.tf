resource "google_bigquery_dataset" "dataset" {
  for_each = var.datasets
  dataset_id                  = each.value.id
  friendly_name               = each.value.name
  location                    = each.value.location
  project = var.project_id
  
  access {
    user_by_email = each.value.user_by_email
    role = each.value.role
  }
}