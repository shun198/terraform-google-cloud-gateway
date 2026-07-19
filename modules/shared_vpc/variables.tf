variable "host_project_id" {
  description = "Shared VPC host project ID"
  type        = string
}

variable "region" {
  type = string
}

variable "service_projects" {
  description = "Map of env => service project identity"
  type = map(object({
    project_id     = string
    project_number = string
  }))
}

variable "subnet_names" {
  description = "Map of env => subnet name in the host VPC"
  type        = map(string)
}

variable "extra_network_users" {
  description = "Optional map of env => list of IAM members granted roles/compute.networkUser on that env subnet"
  type        = map(list(string))
  default     = {}
}

variable "api_dependency" {
  type    = any
  default = null
}
