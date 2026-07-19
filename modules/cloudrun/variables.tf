variable "project_id" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "network_name" {
  description = "VPC network name or projects/HOST/global/networks/NAME"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name or projects/HOST/regions/REGION/subnetworks/NAME"
  type        = string
}

variable "host_project_id" {
  description = "If set, Cloud Run Direct VPC uses Shared VPC resource paths under this host project"
  type        = string
  default     = ""
}

variable "web_image" {
  description = "Container image for Next.js frontend"
  type        = string
}

variable "api_image" {
  description = "Container image for backend API"
  type        = string
}

variable "cpu" {
  type = string
}

variable "memory" {
  type = string
}

variable "min_instances" {
  type = number
}

variable "max_instances" {
  type = number
}

variable "cloud_sql_connection_name" {
  type = string
}

variable "database_url_secret_id" {
  type = string
}

variable "labels" {
  type = map(string)
}

variable "api_dependency" {
  type    = any
  default = null
}
