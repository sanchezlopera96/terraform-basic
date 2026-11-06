############### Contraseña ###############

# RDS no acepta "/", "@", '"' ni espacios; también se evitan ";" y "=" porque
# rompen la cadena de conexión de Npgsql/n8n.
resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!#%*-_+?"
}

############### Subnet Group ###############

# Mínimo dos subredes en AZ distintas (requisito de RDS, y base para Multi-AZ)
resource "aws_db_subnet_group" "main" {
  name       = "sng-db-${terraform.workspace}"
  subnet_ids = var.db_subnets
  tags       = { Name = "SNG-DB-${terraform.workspace}" }
}

############### Parameter Group ###############

# El grupo por defecto no se puede modificar: se crea uno propio para forzar SSL (n8n lo necesita)
resource "aws_db_parameter_group" "main" {
  name   = "pg-db-${terraform.workspace}"
  family = "postgres${split(".", var.db_engine_version)[0]}"

  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }

  tags = { Name = "PG-DB-${terraform.workspace}" }
}

############### RDS PostgreSQL ###############

resource "aws_db_instance" "main" {
  identifier                 = "db-${terraform.workspace}"
  engine                     = "postgres"
  engine_version             = var.db_engine_version
  auto_minor_version_upgrade = true
  instance_class             = var.db_instance_class

  # Arranca en allocated_storage y crece solo hasta max_allocated_storage (GB)
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]
  publicly_accessible    = false
  multi_az               = false

  # Respaldos y mantenimiento (UTC; Colombia = UTC-5). Las ventanas no se pueden cruzar.
  backup_retention_period = var.db_backup_retention_days
  backup_window           = "07:00-08:00"
  maintenance_window      = "sun:08:30-sun:09:30"
  copy_tags_to_snapshot   = true

  # Laboratorio: los cambios se aplican ya y se puede destruir sin snapshot final
  apply_immediately   = true
  skip_final_snapshot = true
  deletion_protection = false

  tags = { Name = "DB-${terraform.workspace}" }
}
