output "lb_ip_address" {
  value = google_compute_global_address.lb.address
}

output "backend_service_id" {
  value = google_compute_backend_service.web.id
}

output "url_map_id" {
  value = google_compute_url_map.web.id
}
