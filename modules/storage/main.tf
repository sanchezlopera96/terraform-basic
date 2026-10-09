############### EFS ###############

resource "aws_efs_file_system" "main" {
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"
  tags             = { Name = "EFS-${terraform.workspace}" }
}

resource "aws_efs_mount_target" "main" {
  count           = length(var.private_subnets)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.private_subnets[count.index]
  security_groups = [var.efs_sg_id]
}

output "efs_id" { value = aws_efs_file_system.main.id }
