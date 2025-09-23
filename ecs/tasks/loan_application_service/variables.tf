variable "tags" {
  description = "Common tags for resources"
}

variable "aws_region" {
  description = "AWS region"
}

variable "task_definition_family_name" {
  description = "Family name of the task definition"
  type = string
  default = "loan-application-service-def-task"
}

variable "task_definition_name" {
  description = "Name of the task definition"
  type = string
  default = "loan-application-service"
}

variable "calculate_capacity_queue_url" {
  description = "URL de la cola de cálculo de capacidad"
  type = string
}

variable "update_loan_application_queue_url" {
  description = "URL de la cola de actualización de la solicitud de préstamo"
  type = string
}

variable "loan_decision_queue_url" {
  description = "URL de la cola de decisiones de préstamo"
  type = string
}

variable "update_reports_queue_url" {
  description = "URL de la cola de reportes"
  type = string
}

variable "db_loan_secret_arn" {
  description = "ARN del secret con las credenciales de la base de datos Loan Application"
  type        = string
}

variable "global_aws_env_secret_arn" {
  description = "ARN del secret global con credenciales AWS"
}

variable "loan_application_ecr_repository_url" {
  description = "URL del repositorio ECR para Reports Service"
  type        = string
}

variable "db_loan_endpoint" {
  type = string
}

variable "auth_service_url" {
  type = string
}