output "efs_id" {
  description = "ID del EFS"
  value       = aws_efs_file_system.main.id
}
