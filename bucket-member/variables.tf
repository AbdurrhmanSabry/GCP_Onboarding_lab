variable "bucket_members" {
  type =map(object({
    member = string
    role = string
    bucket = string
  }))
}