variable "private_subnets" {
  description = "Subredes privadas donde se crean los mount targets (una por AZ)"
  type        = list(string)
}

variable "efs_sg_id" {
  description = "ID del Security Group del EFS"
  type        = string
}
