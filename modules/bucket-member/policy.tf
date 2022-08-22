resource "google_storage_bucket_iam_member" "member" {
  for_each = var.bucket_members
  bucket = each.value.bucket
  role =  each.value.role
  member = each.value.member
}