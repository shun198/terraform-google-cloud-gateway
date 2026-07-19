output "network_id" {
  value = google_compute_network.vpc.id
}

output "network_name" {
  value = google_compute_network.vpc.name
}

output "network_self_link" {
  value = google_compute_network.vpc.self_link
}

output "subnets" {
  description = "Map of env => subnet attributes"
  value = {
    for key, subnet in google_compute_subnetwork.runtime : key => {
      id        = subnet.id
      name      = subnet.name
      self_link = subnet.self_link
      cidr      = subnet.ip_cidr_range
      region    = subnet.region
    }
  }
}

output "private_vpc_connection" {
  value = google_service_networking_connection.private_vpc_connection
}
