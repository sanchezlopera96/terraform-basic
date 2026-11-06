output "master_public_ip" {
  description = "IP pública (EIP) del master"
  value       = aws_eip.master.public_ip
}

output "master_private_ip" {
  description = "IP privada del master"
  value       = aws_instance.master.private_ip
}

output "worker_private_ip" {
  description = "IP privada del worker"
  value       = aws_instance.worker.private_ip
}

output "worker_id" {
  description = "ID de la instancia worker (target del ALB)"
  value       = aws_instance.worker.id
}
