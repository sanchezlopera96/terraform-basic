output "master_sg_id" {
  description = "ID del Security Group del master"
  value       = aws_security_group.master.id
}

output "worker_sg_id" {
  description = "ID del Security Group del worker"
  value       = aws_security_group.worker.id
}

output "efs_sg_id" {
  description = "ID del Security Group del EFS"
  value       = aws_security_group.efs.id
}

output "rds_sg_id" {
  description = "ID del Security Group de la base de datos"
  value       = aws_security_group.rds.id
}

output "alb_sg_id" {
  description = "ID del Security Group del ALB"
  value       = aws_security_group.alb.id
}
