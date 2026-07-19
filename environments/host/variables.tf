variable "host_project_id" {
  description = "Shared VPC host project ID"
  type        = string
}

variable "region" {
  type    = string
  default = "asia-northeast1"
}

variable "name_prefix" {
  type    = string
  default = "study"
}

variable "subnets" {
  description = "Environment subnets created in the host VPC"
  type = map(object({
    cidr = string
  }))
  default = {
    dev = { cidr = "10.10.0.0/20" }
    stg = { cidr = "10.20.0.0/20" }
    prd = { cidr = "10.30.0.0/20" }
  }
}

variable "service_projects" {
  description = "Map of env => service project (must match subnet keys you attach)"
  type = map(object({
    project_id     = string
    project_number = string
  }))
}

variable "extra_network_users" {
  description = "Optional env => IAM members for subnet networkUser (e.g. runtime SAs after first service apply)"
  type        = map(list(string))
  default     = {}
}
