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

module "storage" {
  source          = "./modules/storage"
  private_subnets = slice(module.network.private_subnets, 0, 2)
  efs_sg_id       = module.security.efs_sg_id
}

# Subredes privadas 2 y 3 = capa DB (1a y 1d)
module "db" {
  source                   = "./modules/db"
  db_subnets               = slice(module.network.private_subnets, 2, 4)
  rds_sg_id                = module.security.rds_sg_id
  db_engine_version        = var.db_engine_version
  db_instance_class        = var.db_instance_class
  db_allocated_storage     = var.db_allocated_storage
  db_max_allocated_storage = var.db_max_allocated_storage
  db_backup_retention_days = var.db_backup_retention_days
  db_name                  = var.db_name
  db_username              = var.db_username
}

# Redis en las mismas subredes DB (persistencia fuera del cluster)
module "cache" {
  source                        = "./modules/cache"
  cache_subnets                 = slice(module.network.private_subnets, 2, 4)
  cache_sg_id                   = module.security.cache_sg_id
  cache_engine_version          = var.cache_engine_version
  cache_node_type               = var.cache_node_type
  cache_snapshot_retention_days = var.cache_snapshot_retention_days
}

module "compute" {
  source                = "./modules/compute"
  public_subnet         = module.network.public_subnets[0]
  private_subnet        = module.network.private_subnets[0]
  master_sg_id          = module.security.master_sg_id
  worker_sg_id          = module.security.worker_sg_id
  master_instance_type  = var.master_instance_type
  worker_instance_type  = var.worker_instance_type
  key_name              = var.key_name
  k3s_version           = var.k3s_version
  instance_profile      = var.instance_profile
  efs_id                = module.storage.efs_id
  efs_csi_chart_version = var.efs_csi_chart_version
}

module "load_balancer" {
  source             = "./modules/load_balancer"
  vpc_id             = module.network.vpc_id
  public_subnets     = module.network.public_subnets
  worker_instance_id = module.compute.worker_id
  alb_sg_id          = module.security.alb_sg_id
}
