############### VPC ###############

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags                 = { Name = "VPC-${terraform.workspace}" }
}

############### Internet Gateway ###############

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = var.igw_vp_name }
}

############### Subnets ###############

resource "aws_subnet" "private" {
  count             = length(var.priv_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.priv_subnets[count.index]
  availability_zone = [var.aws_zone_1a, var.aws_zone_1d][count.index % 2]
  tags = {
    Name = "Private-${terraform.workspace}-${count.index < length(var.priv_subnets) / 2 ? "Back" : "DB"}-${[var.aws_zone_1a, var.aws_zone_1d][count.index % 2]}"
    Tier = count.index < length(var.priv_subnets) / 2 ? "Back" : "DB"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.pub_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.pub_subnets[count.index]
  availability_zone       = [var.aws_zone_1a, var.aws_zone_1d][count.index % 2]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-${terraform.workspace}-Front-${[var.aws_zone_1a, var.aws_zone_1d][count.index % 2]}"
    Tier = "Front"
  }
}


############### NAT Gateway ###############

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = var.eip1_vp_name }
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = var.natgw1_vp_name }
}

############### Route Tables ###############
############# Network ACL #############

resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.public[*].id

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = { Name = "NACL-${terraform.workspace}-Public" }
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = { Name = "NACL-${terraform.workspace}-Private" }
}

resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = var.rt_public_vp_name }
}

resource "aws_route_table" "priv" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = var.rt_private_vp_name }
}

resource "aws_route_table_association" "pub" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "priv" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.priv.id
}

output "vpc_id" { value = aws_vpc.main.id }
output "public_subnets" { value = aws_subnet.public[*].id }
output "private_subnets" { value = aws_subnet.private[*].id }