variable "region" {
    type = string
}
variable "zone_one" {
    type = string
}
variable "zone_two" {
    type = string
}
variable "cluster-name" {
    type = string
}
variable "service-account-email" {
    type = string
}
variable "node-machine-type" {
    type = string
}
variable "node-count" {
    type = number
}
variable "vpc_id" {
    type = string
}
variable "authorized-network-cidr" {
    type = string
}
variable "subnet_name" {
    type = string
}
variable "master_ipv4_cidr_block" {
    type = string
}
variable "pods_ipv4_cidr_block" {
    type = string
}
variable "services_ipv4_cidr_block" {
    type = string
}
variable "node_boot_disk_size" {
    type = number
}
variable "node_boot_disk_type" {
    type = string
}
variable "os_image" {
    type = string
}