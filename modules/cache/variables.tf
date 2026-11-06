variable "cache_subnets" {
  description = "Subredes privadas de la capa DB (una por AZ)"
  type        = list(string)
}

variable "cache_sg_id" {
  description = "ID del Security Group de ElastiCache"
  type        = string
}

variable "cache_engine_version" {
  description = "Versión de Redis (la mayor define la familia del parameter group)"
  type        = string
}

variable "cache_node_type" {
  description = "Tipo de nodo de ElastiCache"
  type        = string
}

variable "cache_snapshot_retention_days" {
  description = "Días que se conservan los snapshots automáticos (0 los desactiva)"
  type        = number
}
