output "host_project_id" {
  value = var.host_project_id
}

output "network_name" {
  value = module.networking.network_name
}

output "network_id" {
  value = module.networking.network_id
}

output "network_self_link" {
  value = module.networking.network_self_link
}

output "subnets" {
  value = module.networking.subnets
}

output "service_project_ids" {
  value = module.shared_vpc.service_project_ids
}

output "next_steps" {
  value = <<-EOT
    Host apply 完了後、各 service 環境で:

      cd environments/service
      cp terraform.tfvars.example terraform.tfvars.dev
      # host_project_id / network_* / subnet_* / project_id を設定
      terraform init
      terraform workspace select dev || terraform workspace new dev
      terraform apply -var-file=terraform.tfvars.dev

    Cloud Run runtime SA を作ったあと、必要なら host に戻って
    extra_network_users に SA を追加して再 apply してください。
  EOT
}
