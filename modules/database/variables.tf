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
  description = "Dependency on PSA peering"
  type        = any
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
