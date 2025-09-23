output "reports_service_url" {
  description = "URL pública para acceder al Reports Service"
  value       = "http://${aws_lb.reports_alb.dns_name}"
}