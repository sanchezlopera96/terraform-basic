variable "public_subnets" {
  description = "Subredes públicas, una instancia por cada una"
  type        = list(string)
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