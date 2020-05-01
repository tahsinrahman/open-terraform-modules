output "network" {
  description = "A reference (self_link) to the VPC network"
  value       = google_compute_network.vpc.self_link
}

output "subnet" {
  description = "A reference (self_link) to the public subnetwork"
  value       = google_compute_subnetwork.vpc_subnet.self_link
}

output "subnet_name" {
  description = "Name of the public subnetwork"
  value       = google_compute_subnetwork.vpc_subnet.name
}

output "subnet_cidr_block" {
  value = google_compute_subnetwork.vpc_subnet.ip_cidr_range
}

output "subnet_gateway" {
  value = google_compute_subnetwork.vpc_subnet.gateway_address
}

output "subnet_secondary_cidr_block" {
  value = google_compute_subnetwork.vpc_subnet.secondary_ip_range.0.ip_cidr_range
}

output "subnet_secondary_range_name" {
  value = google_compute_subnetwork.vpc_subnet.secondary_ip_range.0.range_name
}
