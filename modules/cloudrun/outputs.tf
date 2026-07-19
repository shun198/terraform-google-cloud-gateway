output "service_name" {
  value = google_cloud_run_v2_service.app.name
}

output "service_uri" {
  value = google_cloud_run_v2_service.app.uri
}

output "service_id" {
  value = google_cloud_run_v2_service.app.id
}

output "service_account_email" {
  value = google_service_account.runtime.email
}

output "artifact_registry_repository" {
  value = google_artifact_registry_repository.app.name
}

output "artifact_registry_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app.repository_id}"
}
