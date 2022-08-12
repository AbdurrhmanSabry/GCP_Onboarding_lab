variable "region" {
    type = string
}
variable "os_image" {
    type = string
}
variable "machine_type" {
    type = string
}
variable "machine_name" {
    type = string
}
variable "zone" {
    type = string
}
variable "boot_disk_size" {
    type = string
}
variable "vpc_name" {
    type = string
}
variable "subnet_name" {
    type = string
}
variable "project_id" {
    type = string
}
variable "sa-email" {
  type = string
}
variable "startup-script" {
  type = string
  default = "echo 'Hello'"
}