variable "name_prefix" {
  type = string
}

variable "allowed_ingress_cidrs" {
  type    = list(string)
  default = ["*"]
}
