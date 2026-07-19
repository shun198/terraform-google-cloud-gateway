variable "project_id" {
  description = "GCP project ID"
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

variable "domain" {
  description = "Custom domain for the HTTPS load balancer (e.g. app.example.com). Leave empty to skip managed certificate."
  type        = string
  default     = ""
}

variable "cloud_run_web_image" {
  description = "Container image for the Next.js Cloud Run service. Replace after first Artifact Registry push."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "cloud_run_api_image" {
  description = "Container image for the backend API Cloud Run service. Replace after first Artifact Registry push."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "cloud_run_cpu" {
  description = "CPU limit for Cloud Run"
  type        = string
  default     = "1"
}

variable "cloud_run_memory" {
  description = "Memory limit for Cloud Run"
  type        = string
  default     = "512Mi"
}

variable "cloud_run_min_instances" {
  description = "Minimum Cloud Run instances (0 is fine for study)"
  type        = number
  default     = 0
}

variable "cloud_run_max_instances" {
  description = "Maximum Cloud Run instances"
  type        = number
  default     = 10
}

variable "db_tier" {
  description = "Cloud SQL machine tier"
  type        = string
  default     = "db-f1-micro"
}

variable "db_version" {
  description = "Cloud SQL PostgreSQL version"
  type        = string
  default     = "POSTGRES_16"
}

variable "db_name" {
  description = "Application database name"
  type        = string
  default     = "app"
}

variable "db_user" {
  description = "Application database user"
  type        = string
  default     = "app"
}

variable "enable_cdn" {
  description = "Enable Cloud CDN on the frontend backend service"
  type        = bool
  default     = true
}

variable "allowed_ingress_cidrs" {
  description = "CIDRs allowed by Cloud Armor allow rule (default: all). Tighten for study if needed."
  type        = list(string)
  default     = ["*"]
}

variable "labels" {
  description = "Labels applied to supported resources"
  type        = map(string)
  default = {
    purpose = "study"
    stack   = "cloud-run-nextjs"
  }
}
