variable "vpcs" {
  type = map(object({
    vpc_name = string
    project_id = string
    auto_create_subnetworks = bool
    mtu = number
    routing_mode = string
    
  }))
}

variable "subnets" {
  type = map(object({
      #  subnet_name = string
        subnet_cidr = string
        subnet_region = string
        private_ip_google_access  = bool
    }))
}
