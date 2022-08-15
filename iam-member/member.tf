resource "google_project_iam_member" "members" {
  for_each = var.iam_members
  project = var.project_id
  role    = each.value.role
  member = each.value.member
}
# iam_member is better option than iam_binding as iam_binding removes existing permissions