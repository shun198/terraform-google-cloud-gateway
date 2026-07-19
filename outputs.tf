output "lb_ip_address" {
  description = "Global HTTPS Load Balancer IP. Point your DNS A record here."
  value       = module.loadbalancing.lb_ip_address
}

output "cloud_run_service_uri" {
  description = "Cloud Run service URI (internal LB ingress; prefer LB IP for access)"
  value       = module.cloudrun.service_uri
}

output "cloud_run_service_name" {
  value = module.cloudrun.service_name
}

output "artifact_registry_url" {
  description = "Push Next.js images here, then update cloud_run_image"
  value       = module.cloudrun.artifact_registry_url
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

output "vpc_name" {
  value = module.networking.network_name
}

output "waf_policy_name" {
  value = module.security.security_policy_name
}

output "next_steps" {
  description = "Study workflow after terraform apply"
  value       = <<-EOT
    1. Build & push Next.js image:
       gcloud auth configure-docker ${var.region}-docker.pkg.dev
       docker build -t ${module.cloudrun.artifact_registry_url}/web:latest ./examples/nextjs-app
       docker push ${module.cloudrun.artifact_registry_url}/web:latest

    2. Update terraform.tfvars:
       cloud_run_image = "${module.cloudrun.artifact_registry_url}/web:latest"

    3. Re-apply:
       terraform apply

    4. Open http://${module.loadbalancing.lb_ip_address}
       (set domain + DNS A record for HTTPS managed cert)
  EOT
}
