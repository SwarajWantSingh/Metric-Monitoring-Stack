variable "region" {}
variable "name" {}

variable "cidr" {}

variable "azs" {
    type = list(string)
    default = []
}

variable "public_subnets" {
    type = list(string)
    default = []
}

variable "private_subnets" {
    type = list(string)
    default = []
}

