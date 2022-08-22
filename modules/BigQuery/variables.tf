variable "project_id" {
    type = string
}
variable "datasets" {
  type =map(object({
    location = string
    id = string
    name = string
    role = string
    user_by_email = string
  }))
}