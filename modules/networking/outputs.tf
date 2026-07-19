output "network_id" {
  value = google_compute_network.vpc.id
}

output "network_name" {
  value = google_compute_network.vpc.name
}

output "network_self_link" {
  value = google_compute_network.vpc.self_link
}

output "runtime_subnet_id" {
  value = google_compute_subnetwork.runtime.id
}

output "runtime_subnet_name" {
  value = google_compute_subnetwork.runtime.name
}

output "runtime_subnet_self_link" {
  value = google_compute_subnetwork.runtime.self_link
}

output "private_vpc_connection" {
  value = google_service_networking_connection.private_vpc_connection
}
