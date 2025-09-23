output "auth_service_repository_url" {
  value = aws_ecr_repository.auth_service.repository_url
}

output "auth_service_repository_arn" {
  description = "ARN del repositorio ECR del Auth Service"
  value       = aws_ecr_repository.auth_service.arn
}