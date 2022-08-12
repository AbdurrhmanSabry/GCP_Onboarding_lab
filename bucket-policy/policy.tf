data "google_iam_policy" "policy-data" {
  binding {
    role = var.role
    members = var.members
  }
}

resource "google_storage_bucket_iam_policy" "policy" {
  bucket = var.bucket
  policy_data = data.google_iam_policy.policy-data.policy_data
}