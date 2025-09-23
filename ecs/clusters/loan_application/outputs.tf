output "loan_application_service_url" {
  description = "URL pública para acceder al Loan Application Service"
  value       = "http://${aws_lb.loan_alb.dns_name}"
}