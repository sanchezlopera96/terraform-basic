output "alb_dns" {
  description = "DNS público del ALB"
  value       = aws_lb.main.dns_name
}
