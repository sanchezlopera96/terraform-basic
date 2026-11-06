# Global Variables
aws_region  = "us-east-1"
aws_zone_1a = "us-east-1a"
aws_zone_1d = "us-east-1d"
aws_profile = "PPatrones"

# Network Variables
vpc_cidr     = "192.168.0.0/24"
pub_subnets  = ["192.168.0.0/27", "192.168.0.32/27"]
priv_subnets = ["192.168.0.64/27", "192.168.0.96/27", "192.168.0.128/27", "192.168.0.160/27"]


igw_vp_name        = "IGW_ITMLab_VP"
eip1_vp_name       = "EIP_ITMLab_VP_NatGW_1"
natgw1_vp_name     = "NGW_ITMLab_VP_1"
rt_public_vp_name  = "RT_ITMLab_VP_Public"
rt_private_vp_name = "RT_ITMLab_VP_Private"

# Compute Variables
master_instance_type = "t3.medium"
worker_instance_type = "t3.large"
