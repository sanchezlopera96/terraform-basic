output "db_address" {
  description = "Host de la base de datos RDS"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "Puerto de la base de datos RDS"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Nombre de la base de datos inicial"
  value       = aws_db_instance.main.db_name
}

output "db_username" {
  description = "Usuario maestro de la base de datos"
  value       = aws_db_instance.main.username
}

output "db_password" {
  description = "Contraseña del usuario maestro (generada por Terraform)"
  value       = random_password.db.result
  sensitive   = true
}
