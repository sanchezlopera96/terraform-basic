############### Subnet Group ###############

resource "aws_db_subnet_group" "main" {
  name       = "sng-db-${terraform.workspace}"
  subnet_ids = var.db_subnets
  tags       = { Name = "SNG-DB-${terraform.workspace}" }
}

############### RDS PostgreSQL ###############

resource "aws_db_instance" "main" {
  identifier     = "db-${terraform.workspace}"
  engine         = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]
  publicly_accessible    = false
  multi_az               = false

  # Laboratorio: se puede destruir sin snapshot final
  skip_final_snapshot = true
  deletion_protection = false

  tags = { Name = "DB-${terraform.workspace}" }
}

output "db_address" { value = aws_db_instance.main.address }
output "db_port" { value = aws_db_instance.main.port }
output "db_name" { value = aws_db_instance.main.db_name }
