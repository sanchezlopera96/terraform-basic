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
