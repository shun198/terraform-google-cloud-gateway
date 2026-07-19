locals {
  labels = merge(var.labels, {
    environment = var.environment
  })
}

module "security" {
  source = "../../modules/security"

  name_prefix           = "${var.name_prefix}-${var.environment}"
  allowed_ingress_cidrs = var.allowed_ingress_cidrs
}

module "database" {
  source = "../../modules/database"

  name_prefix = "${var.name_prefix}-${var.environment}"
  region      = var.region
  network_id  = var.network_id
  # PSA peering lives on the Shared VPC host; create host stack first
  db_tier        = var.db_tier
  db_version     = var.db_version
  db_name        = var.db_name
  db_user        = var.db_user
  labels         = local.labels
  api_dependency = google_project_service.required
}

module "cloudrun" {
  source = "../../modules/cloudrun"

  project_id                = var.project_id
  name_prefix               = "${var.name_prefix}-${var.environment}"
  region                    = var.region
  host_project_id           = var.host_project_id
  network_name              = var.network_name
  subnet_name               = var.subnet_name
  web_image                 = var.cloud_run_web_image
  api_image                 = var.cloud_run_api_image
  cpu                       = var.cloud_run_cpu
  memory                    = var.cloud_run_memory
  min_instances             = var.cloud_run_min_instances
  max_instances             = var.cloud_run_max_instances
  cloud_sql_connection_name = module.database.instance_connection_name
  database_url_secret_id    = module.database.database_url_secret_id
  labels                    = local.labels
  api_dependency            = google_project_service.required
}

# Runtime SA needs networkUser on the Shared VPC subnet (host project)
resource "google_compute_subnetwork_iam_member" "runtime_network_user" {
  project    = var.host_project_id
  region     = var.region
  subnetwork = var.subnet_name
  role       = "roles/compute.networkUser"
  member     = module.cloudrun.service_account_member
}

module "loadbalancing" {
  source = "../../modules/loadbalancing"

  name_prefix               = "${var.name_prefix}-${var.environment}"
  region                    = var.region
  web_service_name          = module.cloudrun.web_service_name
  api_service_name          = module.cloudrun.api_service_name
  security_policy_self_link = module.security.security_policy_self_link
  enable_cdn                = var.enable_cdn
  domain                    = var.domain
}
