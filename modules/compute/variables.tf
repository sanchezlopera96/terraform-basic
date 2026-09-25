variable "public_subnet" {
  description = "Subred pública para la instancia"
  type        = string
}

variable "sg_id" {
  description = "ID del Security Group de la instancia"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
}

variable "key_name" {
  description = "Nombre de la llave SSH"
  type        = string
}