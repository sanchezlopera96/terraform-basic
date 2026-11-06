############### Compute ###############

output "master_public_ip" {
  description = "IP pública (EIP) del master: SSH, kubectl y túnel hacia la base"
  value       = module.compute.master_public_ip
}

output "master_private_ip" {
  description = "IP privada del master"
  value       = module.compute.master_private_ip
}

output "worker_private_ip" {
  description = "IP privada del worker"
  value       = module.compute.worker_private_ip
}

############### Load Balancer ###############

output "alb_dns" {
  description = "DNS público del ALB (entrada a la aplicación)"
  value       = module.load_balancer.alb_dns
}

############### Storage ###############

output "efs_id" {
  description = "ID del EFS usado por el StorageClass efs-sc"
  value       = module.storage.efs_id
}

############### Base de datos ###############

output "db_address" {
  description = "Host de la base de datos RDS (para la cadena de conexión)"
  value       = module.db.db_address
}

output "db_port" {
  description = "Puerto de la base de datos RDS"
  value       = module.db.db_port
}

output "db_name" {
  description = "Nombre de la base de datos inicial"
  value       = module.db.db_name
}

output "db_username" {
  description = "Usuario maestro de la base de datos"
  value       = module.db.db_username
}

output "db_password" {
  description = "Contraseña de la base de datos (ver con: terraform output -raw db_password)"
  value       = module.db.db_password
  sensitive   = true
}

############### Cache (Redis) ###############

output "cache_address" {
  description = "Endpoint primario de Redis (conexión con TLS: rediss://)"
  value       = module.cache.cache_address
}

output "cache_port" {
  description = "Puerto de Redis"
  value       = module.cache.cache_port
}

output "cache_auth_token" {
  description = "Auth token de Redis (ver con: terraform output -raw cache_auth_token)"
  value       = module.cache.cache_auth_token
  sensitive   = true
}
