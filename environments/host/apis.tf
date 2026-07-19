locals {
  required_apis = [
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "dns.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "iam.googleapis.com",
  ]
}

resource "google_project_service" "required" {
  for_each = toset(local.required_apis)

  project            = var.host_project_id
  service            = each.value
  disable_on_destroy = false
}
