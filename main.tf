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
  source               = "./modules/compute"
  public_subnet        = module.network.public_subnets[0]
  private_subnet       = module.network.private_subnets[0]
  master_sg_id         = module.security.master_sg_id
  worker_sg_id         = module.security.worker_sg_id
  master_instance_type = var.master_instance_type
  worker_instance_type = var.worker_instance_type
  key_name             = var.key_name
  k3s_version          = var.k3s_version
}

module "load_balancer" {
  source             = "./modules/load_balancer"
  vpc_id             = module.network.vpc_id
  public_subnets     = module.network.public_subnets
  worker_instance_id = module.compute.worker_id
  alb_sg_id          = module.security.alb_sg_id
}

output "master_public_ip" { value = module.compute.master_public_ip }
output "master_private_ip" { value = module.compute.master_private_ip }
output "worker_private_ip" { value = module.compute.worker_private_ip }
output "alb_dns" { value = module.load_balancer.alb_dns }
