output "environment" {
  value = var.environment
}

output "lb_ip_address" {
  description = "Global HTTPS Load Balancer IP. Point your DNS A record here."
  value       = module.loadbalancing.lb_ip_address
}

output "web_service_name" {
  value = module.cloudrun.web_service_name
}

output "web_service_uri" {
  value = module.cloudrun.web_service_uri
}

output "api_service_name" {
  value = module.cloudrun.api_service_name
}

output "api_service_uri" {
  value = module.cloudrun.api_service_uri
}

output "artifact_registry_url" {
  value = module.cloudrun.artifact_registry_url
}

output "cloud_sql_connection_name" {
  value = module.database.instance_connection_name
}

output "cloud_sql_private_ip" {
  value = module.database.private_ip_address
}

output "database_url_secret_id" {
  value = module.database.database_url_secret_id
}

output "runtime_service_account_email" {
  value = module.cloudrun.service_account_email
}

output "waf_policy_name" {
  value = module.security.security_policy_name
}

output "next_steps" {
  value = <<-EOT
    1. Build & push images:
       gcloud auth configure-docker ${var.region}-docker.pkg.dev
       docker build -t ${module.cloudrun.artifact_registry_url}/web:latest ../../examples/nextjs-app
       docker build -t ${module.cloudrun.artifact_registry_url}/api:latest ../../examples/api
       docker push ${module.cloudrun.artifact_registry_url}/web:latest
       docker push ${module.cloudrun.artifact_registry_url}/api:latest

    2. Update tfvars:
       cloud_run_web_image = "${module.cloudrun.artifact_registry_url}/web:latest"
       cloud_run_api_image = "${module.cloudrun.artifact_registry_url}/api:latest"

    3. Re-apply, then open:
       Frontend: http://${module.loadbalancing.lb_ip_address}
       API:      http://${module.loadbalancing.lb_ip_address}/api/health
  EOT
}
