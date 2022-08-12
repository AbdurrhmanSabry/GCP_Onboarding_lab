resource "google_project_iam_binding" "gcr_reader" {
  project = var.project_id
  role    = var.role

  members = var.members
}
