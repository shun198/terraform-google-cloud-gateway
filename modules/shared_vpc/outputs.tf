output "host_project_id" {
  value = google_compute_shared_vpc_host_project.host.project
}

output "service_project_ids" {
  value = {
    for key, sp in google_compute_shared_vpc_service_project.service : key => sp.service_project
  }
}
