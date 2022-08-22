variable "id" {
  type =string
  description = "The camel case role id to use for this role. Cannot contain - characters."
}
variable "title" {
  type =string
  description = " A human-readable title for the role"
}
variable "permissions" {
  type =list(string)
  description = "A list of the permissions this role grants when bound in an IAM policy."
}
variable "project_id" {
  type =string
}
