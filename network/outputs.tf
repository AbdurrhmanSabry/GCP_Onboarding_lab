output "vpc_name" {
  value = google_compute_network.vpc.name
}
output "subnet_name" {
  value = google_compute_subnetwork.subnetwork.name
}
output "vpc_id" {
  value = google_compute_network.vpc.id
}
output "subnet_cidr" {
  value = google_compute_subnetwork.subnetwork.ip_cidr_range
}