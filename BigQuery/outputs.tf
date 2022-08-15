output "datasets_info" {
  value = tomap(google_bigquery_dataset.dataset)
}