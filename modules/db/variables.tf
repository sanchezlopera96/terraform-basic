variable "db_subnets" {
  description = "Subredes privadas de la capa DB (una por AZ)"
  type        = list(string)
}

variable "rds_sg_id" {
  description = "ID del Security Group de la base de datos"
  type        = string
}

variable "db_engine_version" {
  description = "Versión de PostgreSQL (solo la mayor toma la última menor disponible)"
  type        = string
}

variable "db_instance_class" {
  description = "Tipo de instancia de la base de datos"
  type        = string
}

variable "db_allocated_storage" {
  description = "Almacenamiento inicial en GB"
  type        = number
}

variable "db_max_allocated_storage" {
  description = "Hasta cuántos GB puede crecer el almacenamiento de forma automática"
  type        = number
}

variable "db_backup_retention_days" {
  description = "Días que se conservan los respaldos automáticos (0 los desactiva)"
  type        = number
}

variable "db_name" {
  description = "Nombre de la base de datos inicial"
  type        = string
}

variable "db_username" {
  description = "Usuario maestro"
  type        = string
}
