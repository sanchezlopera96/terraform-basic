module "network" {
  source             = "./modules/network"
  vpc_cidr           = var.vpc_cidr
  pub_subnets        = var.pub_subnets
  priv_subnets       = var.priv_subnets
  aws_zone_1a        = var.aws_zone_1a
  aws_zone_1d        = var.aws_zone_1d
  aws_profile        = var.aws_profile
  igw_vp_name        = var.igw_vp_name
  eip1_vp_name       = var.eip1_vp_name
  natgw1_vp_name     = var.natgw1_vp_name
  rt_public_vp_name  = var.rt_public_vp_name
  rt_private_vp_name = var.rt_private_vp_name
}