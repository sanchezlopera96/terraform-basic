variable "aws_zone_1a" {
  description = "Zona de disponibilidad aws_zone_1a"
  type        = string
}

variable "aws_zone_1d" {
  description = "Zona de disponibilidad aws_zone_1d"
  type        = string
}

variable "aws_profile" {
  description = "Perfil AWS aws_profile"
  type        = string
}


variable "vpc_cidr" {
  description = "Rango CIDR para la VPC"
  type        = string
}

variable "pub_subnets" {
  description = "Lista de CIDRs para subredes públicas"
  type        = list(string)
}

variable "priv_subnets" {
  description = "Lista de CIDRs para subredes privadas"
  type        = list(string)
}

variable "igw_vp_name" {
  description = "Internet Gateway"
  type        = string
}

variable "eip1_vp_name" {
  description = "EIP Name (NAT Gateway 1)"
  type        = string
}

variable "natgw1_vp_name" {
  description = "NAT Gateway Name (1)"
  type        = string
}

variable "rt_public_vp_name" {
  description = "Route Table Name (Public)"
  type        = string
}

variable "rt_private_vp_name" {
  description = "Route Table Name (Private)"
  type        = string
}