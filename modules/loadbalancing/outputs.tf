output "lb_ip_address" {
  value = google_compute_global_address.lb.address
}

output "web_backend_service_id" {
  value = google_compute_backend_service.web.id
}

output "api_backend_service_id" {
  value = google_compute_backend_service.api.id
}

output "url_map_id" {
  value = google_compute_url_map.web.id
}
