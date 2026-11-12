output "alb_dns" {
  description = "DNS público del ALB"
  value       = aws_lb.main.dns_name
}

output "n8n_url" {
  description = "URL pública de n8n (listener dedicado del ALB)"
  value       = "http://${aws_lb.main.dns_name}:${var.n8n_public_port}/"
}
