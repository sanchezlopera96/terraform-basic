# Region
variable "aws_region" {
  default = "us-east-1"
}

# Zone 
variable "aws_zone_1a" {
  default = "us-east-1a"
}

variable "aws_zone_1d" {
  default = "us-east-1d"
}

# Profile
variable "aws_profile" {
  default = "PPatrones"
}

# VPC CIDR (/24)
variable "vpc_cidr" {
  default = "192.168.0.0/24"
}

# Subredes públicas
variable "pub_subnets" {
  type = list(string)
}

# Subredes privadas
variable "priv_subnets" {
  type = list(string)
}

# Internet Gateway
variable "igw_vp_name" {
  default = "IGW_ITMLab_VP"
}

# EIP Name (NAT Gateway 1)
variable "eip1_vp_name" {
  default = "EIP_ITMLab_VP_NatGW_1"
}

# NAT Gateway Name (1)
variable "natgw1_vp_name" {
  default = "NGW_ITMLab_VP_1"
}

# Route Table Name (Public)
variable "rt_public_vp_name" {
  default = "RT_ITMLab_VP_Public"
}

# Route Table Name (Private)
variable "rt_private_vp_name" {
  default = "RT_ITMLab_VP_Private"
}

# Tipo de instancia EC2
variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
}

# Llave SSH
variable "key_name" {
  description = "Nombre de la llave SSH"
  type        = string
}

# CIDR con acceso SSH (usar TF_VAR_admin_cidr, no ponerlo en .tfvars)
variable "admin_cidr" {
  description = "CIDR con acceso a SSH (22)"
  type        = string
}
