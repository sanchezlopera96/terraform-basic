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

module "security" {
  source     = "./modules/security"
  vpc_id     = module.network.vpc_id
  admin_cidr = var.admin_cidr
}

module "compute" {
  source        = "./modules/compute"
  public_subnet = module.network.public_subnets[0]
  sg_id         = module.security.sg_id
  instance_type = var.instance_type
  key_name      = var.key_name
}

module "load_balancer" {
  source             = "./modules/load_balancer"
  vpc_id             = module.network.vpc_id
  public_subnets     = module.network.public_subnets
  worker_instance_id = module.compute.instance_id
  alb_sg_id          = module.security.alb_sg_id
}

output "ec2_ip" { value = module.compute.ec2_ip }
output "alb_dns" { value = module.load_balancer.alb_dns }
