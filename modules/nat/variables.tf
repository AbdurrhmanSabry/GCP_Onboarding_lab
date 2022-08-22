variable "nat_details" {
  type = map(object({
    project_id = string
    source_ip_ranges_to_nat =list(string)
    nat_name = string
    nat_ip_allocate_option = string
    source_subnetwork_ip_ranges_to_nat =string 
  }))
}

variable "routers" {
  type = map(object({
    vpc_id = string
    subnet_region = string
    subnet_name = string
    bgp_asn = number
  }))
}