variable "public_subnet" {
  description = "Subred pública para el master"
  type        = string
}

variable "private_subnet" {
  description = "Subred privada para el worker"
  type        = string
}

variable "master_sg_id" {
  description = "ID del Security Group del master"
  type        = string
}

variable "worker_sg_id" {
  description = "ID del Security Group del worker"
  type        = string
}

variable "master_instance_type" {
  description = "Tipo de instancia del master (Control Plane)"
  type        = string
}

variable "worker_instance_type" {
  description = "Tipo de instancia del worker"
  type        = string
}

variable "key_name" {
  description = "Nombre de la llave SSH"
  type        = string
}

variable "instance_profile" {
  description = "Instance profile IAM de los nodos (permisos del EFS CSI driver)"
  type        = string
}

variable "efs_id" {
  description = "ID del EFS para el StorageClass efs-sc"
  type        = string
}

variable "efs_csi_chart_version" {
  description = "Versión del chart Helm aws-efs-csi-driver"
  type        = string
}

variable "k3s_version" {
  description = "Versión de k3s a instalar"
  type        = string
}
