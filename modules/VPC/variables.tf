#variable "create_vpc" {
#description = "Controls if VPC should be created (it affects almost all resources)"
# type        = bool
# default     = true
#}

variable "name" {}

variable "cidr" {}

variable "azs" {
  type = list(string)
}

variable "public_subnets" {
  type    = list(string)
  default = []
}

variable "public_subnet_suffix" {
  description = "suffix for public subnets"
  type        = string
  default     = "public"
}

variable "private_subnets" {
  type    = list(string)
  default = []
}

variable "private_subnet_suffix" {
  description = "suffix for private subnets"
  type        = string
  default     = "private"
}

variable "create_multiple_pub_route_tables" {
  description = "Indicates whether to create a separate route table for each public subnet. Default: `false`"
  type        = bool
  default     = false
}

variable "create_multiple_pvt_route_tables" {
  description = "Indicates whether to create a separate route table for each private subnet. Default: `false`"
  type        = bool
  default     = false
}