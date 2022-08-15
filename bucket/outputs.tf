output "buckets_info" {
   value = tomap(google_storage_bucket.bucket)
}