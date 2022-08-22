output "vpc_details" {
  value = tomap(google_compute_network.vpc)
}
output "subnet_details" {
  value = tomap(google_compute_subnetwork.subnetwork)
}