provider "aws" {
    region = var.region
}
module "vpc" {
    source = "../../modules/VPC"
    cidr = var.cidr 
    name = var.name
    azs = var.azs
    public_subnets = var.public_subnets
    private_subnets = var.private_subnets
}

/*
output "pub_subnet_ids_final" {
  value = module.vpc.pub_subnet_ids
}

output "pvt_subnet_ids_final" {
  value = module.vpc.pvt_subnet_ids
}
*/


