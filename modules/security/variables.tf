variable "vpc_id" {
  description = "ID de la VPC creada en el módulo network"
  type        = string
}

variable "admin_cidr" {
  description = "CIDR con acceso a SSH (22)"
  type        = string
  default     = "0.0.0.0/0"
}
