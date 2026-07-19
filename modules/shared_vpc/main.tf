# Shared VPC host enablement + service project attachment + subnet IAM
resource "google_compute_shared_vpc_host_project" "host" {
  project = var.host_project_id

  depends_on = [var.api_dependency]
}

resource "google_compute_shared_vpc_service_project" "service" {
  for_each = var.service_projects

  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = each.value.project_id
}

locals {
  # env key => { project_id, project_number, subnet_name }
  subnet_bindings = {
    for env, svc in var.service_projects : env => {
      project_id     = svc.project_id
      project_number = svc.project_number
      subnet_name    = var.subnet_names[env]
    }
  }
}

# Cloud Run Service Agent (Direct VPC Egress on Shared VPC)
resource "google_compute_subnetwork_iam_member" "run_service_agent" {
  for_each = local.subnet_bindings

  project    = var.host_project_id
  region     = var.region
  subnetwork = each.value.subnet_name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:service-${each.value.project_number}@serverless-robot-prod.iam.gserviceaccount.com"

  depends_on = [google_compute_shared_vpc_service_project.service]
}

# Google APIs Service Agent in the service project
resource "google_compute_subnetwork_iam_member" "cloud_services" {
  for_each = local.subnet_bindings

  project    = var.host_project_id
  region     = var.region
  subnetwork = each.value.subnet_name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${each.value.project_number}@cloudservices.gserviceaccount.com"

  depends_on = [google_compute_shared_vpc_service_project.service]
}

# Optional extra members (e.g. Cloud Run runtime SA created in service stack)
resource "google_compute_subnetwork_iam_member" "extra" {
  for_each = {
    for item in flatten([
      for env, members in var.extra_network_users : [
        for member in members : {
          key         = "${env}:${member}"
          env         = env
          member      = member
          subnet_name = var.subnet_names[env]
        }
      ]
    ]) : item.key => item
  }

  project    = var.host_project_id
  region     = var.region
  subnetwork = each.value.subnet_name
  role       = "roles/compute.networkUser"
  member     = each.value.member

  depends_on = [google_compute_shared_vpc_service_project.service]
}
