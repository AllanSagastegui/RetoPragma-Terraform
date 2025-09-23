variable "tags" {
  description = "Common tags for resources"
}

variable "aws_region" {
  description = "AWS region"
}

variable "update_reports_queue_url" {
  description = "SQS URL for the update reports queue"
}

variable "global_aws_env_secret_arn" {
  description = "ARN del secret global con credenciales AWS"
}

variable "reports_ecr_repository_url" {
  description = "URL del repositorio ECR para Reports Service"
  type        = string
}

variable "reports_dynamo_table_arn" {
  description = "ARN de la tabla DynamoDB para Reports"
  type        = string
  
}