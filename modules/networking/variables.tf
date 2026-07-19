variable "project_id" {
  description = "Host project ID where the VPC lives"
  type        = string
}

variable "name_prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "subnets" {
  description = "Map of environment key => subnet config (e.g. dev/stg/prd)"
  type = map(object({
    cidr = string
  }))
}

variable "api_dependency" {
  description = "Opaque dependency to wait for API enablement"
  type        = any
  default     = null
}
