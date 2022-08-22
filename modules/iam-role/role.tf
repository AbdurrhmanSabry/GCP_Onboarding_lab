resource "google_project_iam_custom_role" "custom-role" {
  role_id     = var.id
  title       = var.title
  permissions = var.permissions
  project = var.project_id
}
