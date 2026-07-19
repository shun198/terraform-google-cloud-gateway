variable "name_prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "network_id" {
  type = string
}

variable "private_vpc_connection" {
  description = "Dependency on PSA peering (set in host stack; optional when PSA already exists)"
  type        = any
  default     = null
}

variable "db_tier" {
  type = string
}

variable "db_version" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "labels" {
  type = map(string)
}

variable "api_dependency" {
  type    = any
  default = null
}
