module "networking" {
  source = "../../modules/networking"

  project_id     = var.host_project_id
  name_prefix    = var.name_prefix
  region         = var.region
  subnets        = var.subnets
  api_dependency = google_project_service.required
}

module "shared_vpc" {
  source = "../../modules/shared_vpc"

  host_project_id     = var.host_project_id
  region              = var.region
  service_projects    = var.service_projects
  subnet_names        = { for env, s in module.networking.subnets : env => s.name }
  extra_network_users = var.extra_network_users
  api_dependency      = google_project_service.required

  depends_on = [module.networking]
}
