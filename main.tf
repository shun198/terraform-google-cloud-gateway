module "networking" {
  source = "./modules/networking"

  name_prefix    = var.name_prefix
  region         = var.region
  api_dependency = google_project_service.required
}

module "security" {
  source = "./modules/security"

  name_prefix           = var.name_prefix
  allowed_ingress_cidrs = var.allowed_ingress_cidrs
}

module "database" {
  source = "./modules/database"

  name_prefix            = var.name_prefix
  region                 = var.region
  network_id             = module.networking.network_id
  private_vpc_connection = module.networking.private_vpc_connection
  db_tier                = var.db_tier
  db_version             = var.db_version
  db_name                = var.db_name
  db_user                = var.db_user
  labels                 = var.labels
  api_dependency         = google_project_service.required
}

module "cloudrun" {
  source = "./modules/cloudrun"

  project_id                = var.project_id
  name_prefix               = var.name_prefix
  region                    = var.region
  network_name              = module.networking.network_name
  subnet_name               = module.networking.runtime_subnet_name
  image                     = var.cloud_run_image
  cpu                       = var.cloud_run_cpu
  memory                    = var.cloud_run_memory
  min_instances             = var.cloud_run_min_instances
  max_instances             = var.cloud_run_max_instances
  cloud_sql_connection_name = module.database.instance_connection_name
  database_url_secret_id    = module.database.database_url_secret_id
  labels                    = var.labels
  api_dependency            = google_project_service.required
}

module "loadbalancing" {
  source = "./modules/loadbalancing"

  name_prefix               = var.name_prefix
  region                    = var.region
  cloud_run_service_name    = module.cloudrun.service_name
  security_policy_self_link = module.security.security_policy_self_link
  enable_cdn                = var.enable_cdn
  domain                    = var.domain
}
