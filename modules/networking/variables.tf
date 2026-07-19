variable "name_prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "runtime_subnet_cidr" {
  type    = string
  default = "10.10.0.0/20"
}

variable "api_dependency" {
  description = "Opaque dependency to wait for API enablement"
  type        = any
  default     = null
}
