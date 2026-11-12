variable "vpc_id" {
  description = "ID de la VPC creada en el módulo network"
  type        = string
}

variable "admin_cidr" {
  description = "CIDR con acceso a SSH (22)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "n8n_public_port" {
  description = "Puerto del ALB para n8n (abierto solo a admin_cidr)"
  type        = number
}

variable "n8n_node_port" {
  description = "NodePort de n8n en el worker (abierto solo al ALB)"
  type        = number
}
