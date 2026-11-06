############### Auth token ###############

# Contraseña de Redis (solo se permite con cifrado en tránsito). Sin caracteres especiales:
# ElastiCache no acepta "@", '"' ni "/".
resource "random_password" "auth" {
  length  = 32
  special = false
}

############### Subnet Group ###############

resource "aws_elasticache_subnet_group" "main" {
  name       = "sng-cache-${terraform.workspace}"
  subnet_ids = var.cache_subnets
  tags       = { Name = "SNG-Cache-${terraform.workspace}" }
}

############### Parameter Group ###############

# noeviction: si la memoria se llena, Redis rechaza escrituras en vez de borrar llaves,
# así no se pierden los trabajos en cola de n8n cuando un pod se cae.
resource "aws_elasticache_parameter_group" "main" {
  name   = "pg-cache-${terraform.workspace}"
  family = "redis${split(".", var.cache_engine_version)[0]}"

  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }

  tags = { Name = "PG-Cache-${terraform.workspace}" }
}

############### ElastiCache (Redis) ###############

# replication_group y no cluster: permite cifrado en tránsito y auth token,
# y deja crecer a réplicas o Multi-AZ sin cambiar de recurso.
resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "cache-${terraform.workspace}"
  description          = "Redis para colas y sesiones de n8n"

  engine                     = "redis"
  engine_version             = var.cache_engine_version
  auto_minor_version_upgrade = true
  node_type                  = var.cache_node_type
  port                       = 6379

  # Un solo nodo (laboratorio): sin réplicas ni failover
  num_cache_clusters         = 1
  automatic_failover_enabled = false
  multi_az_enabled           = false

  subnet_group_name    = aws_elasticache_subnet_group.main.name
  parameter_group_name = aws_elasticache_parameter_group.main.name
  security_group_ids   = [var.cache_sg_id]

  # Cifrado en reposo y en tránsito (TLS); el cliente se conecta con rediss://
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = random_password.auth.result

  # Respaldos y mantenimiento (UTC). Las ventanas no se pueden cruzar.
  snapshot_retention_limit = var.cache_snapshot_retention_days
  snapshot_window          = "06:00-07:00"
  maintenance_window       = "sun:09:30-sun:10:30"

  apply_immediately = true

  tags = { Name = "Cache-${terraform.workspace}" }
}
