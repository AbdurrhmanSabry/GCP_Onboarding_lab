resource "google_project_iam_binding" "container_admin" {
  project = var.project_id
  role    = "projects/${var.project_id}/roles/gkeCredentialRole"

  members = [
    "serviceAccount:${module.sa-buckets-reader.sa-email}",
  ]
  # condition {
  #   title       = "container admin"
  #   description = "limiting the access to  one cluster"
  #   expression  = "resource.name ==  \"projects/seraphic-lock-358517/zones/us-central1-c/clusters/mycluster\" "
  # }
}