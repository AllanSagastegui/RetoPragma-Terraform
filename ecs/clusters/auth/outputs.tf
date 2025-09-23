output "auth_service_url" {
  description = "URL pública para acceder al Auth Service"
  value       = "http://${aws_lb.auth_alb.dns_name}"
}