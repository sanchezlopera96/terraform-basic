output "cache_address" {
  description = "Endpoint primario de Redis"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "cache_port" {
  description = "Puerto de Redis"
  value       = aws_elasticache_replication_group.main.port
}

output "cache_auth_token" {
  description = "Auth token (contraseña) de Redis, generado por Terraform"
  value       = random_password.auth.result
  sensitive   = true
}
