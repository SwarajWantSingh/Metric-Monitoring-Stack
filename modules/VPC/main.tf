locals {
  #create_vpc = var.create_vpc
  len_public_subnets  = length(var.public_subnets)
  len_private_subnets = length(var.private_subnets)
}
resource "aws_vpc" "main" {
  #count = local.create_vpc ? 1 : 0
  cidr_block       = var.cidr
  instance_tenancy = "default"

  tags = {
    Name = var.name
  }
}

##################################################################### 
#public_subnets
#####################################################################

locals {
  create_public_subnets = local.len_public_subnets > 0
}

resource "aws_subnet" "public" {
  count             = local.create_public_subnets ? local.len_public_subnets : 0
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnets, count.index)
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = format("${var.name}-${var.public_subnet_suffix}-%s", element(var.azs, count.index))
  }

}

output "pub_subnet_ids" {
  value = aws_subnet.public[*].id
}

locals {
  num_public_route_tables = var.create_multiple_pub_route_tables ? local.len_public_subnets : 1
}

resource "aws_route_table" "public" {
  count  = local.create_public_subnets ? local.num_public_route_tables : 0
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-${var.public_subnet_suffix}-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = local.create_public_subnets ? local.len_public_subnets : 0
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mygw[0].id
}

#####################################################################
#private_subnets
#####################################################################

locals {
  create_private_subnets = local.len_private_subnets > 0
}

resource "aws_subnet" "private" {
  count             = local.create_private_subnets ? local.len_private_subnets : 0
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = format("${var.name}-${var.private_subnet_suffix}-%s", element(var.azs, count.index))
  }

}

output "pvt_subnet_ids" {
  value = aws_subnet.private[*].id
}


locals {
  num_private_route_tables = var.create_multiple_pvt_route_tables ? local.len_private_subnets : 1
}

resource "aws_route_table" "private" {
  count  = local.create_private_subnets ? local.num_private_route_tables : 0
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-${var.private_subnet_suffix}-route-table"
  }
}

resource "aws_route_table_association" "private" {
  count          = local.create_private_subnets ? local.len_private_subnets : 0
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private[0].id
}

##################################################################### 
#Internet gateway
#####################################################################
resource "aws_internet_gateway" "mygw" {
  count  = local.create_public_subnets ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = format("${var.name}-%s", "igw")
  }
}

####################################################################
#NAT gateway
####################################################################


locals {
  create_nat_gateway = local.create_private_subnets ? true : false
  nat_gateway_count  = length(var.azs)
}

resource "aws_nat_gateway" "this" {
  count = local.create_nat_gateway ? local.nat_gateway_count : 0
  subnet_id = aws_subnet.private[count.index].id

  tags = {
    Name = format("${var.name}-${var.private_subnet_suffix}-%s", element(var.azs,count.index))
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.mygw]
}



