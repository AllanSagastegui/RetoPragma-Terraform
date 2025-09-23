variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "auth_ecr_repository_url" {
  description = "ECR image for the Auth service"
  type        = string
}

variable "db_auth_secret_arn" {
  description = "ARN del secret con las credenciales de la base de datos Auth"
  type        = string
}

variable "db_auth_endpoint" {
  type = string
}