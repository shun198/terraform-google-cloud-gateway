variable "project_id" {
  description = "Service project ID (dev/stg/prd app project)"
  type        = string
}

variable "host_project_id" {
  description = "Shared VPC host project ID"
  type        = string
}

variable "network_name" {
  description = "Shared VPC network name in the host project"
  type        = string
}

variable "network_id" {
  description = "Shared VPC network ID/self link (for Cloud SQL private IP)"
  type        = string
}

variable "subnet_name" {
  description = "Shared VPC subnet name for this environment"
  type        = string
}

variable "region" {
  description = "Primary region for regional resources"
  type        = string
  default     = "asia-northeast1"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "study"
}

variable "environment" {
  description = "Environment name (dev/stg/prd)"
  type        = string
}

variable "domain" {
  description = "Custom domain for the HTTPS load balancer. Leave empty to skip managed certificate."
  type        = string
  default     = ""
}

variable "cloud_run_web_image" {
  type    = string
  default = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "cloud_run_api_image" {
  type    = string
  default = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "cloud_run_cpu" {
  type    = string
  default = "1"
}

variable "cloud_run_memory" {
  type    = string
  default = "512Mi"
}

variable "cloud_run_min_instances" {
  type    = number
  default = 0
}

variable "cloud_run_max_instances" {
  type    = number
  default = 10
}

variable "db_tier" {
  type    = string
  default = "db-f1-micro"
}

variable "db_version" {
  type    = string
  default = "POSTGRES_16"
}

variable "db_name" {
  type    = string
  default = "app"
}

variable "db_user" {
  type    = string
  default = "app"
}

variable "enable_cdn" {
  type    = bool
  default = true
}

variable "allowed_ingress_cidrs" {
  type    = list(string)
  default = ["*"]
}

variable "labels" {
  type = map(string)
  default = {
    purpose = "study"
    stack   = "cloud-run-nextjs"
  }
}
