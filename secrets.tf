resource "aws_secretsmanager_secret" "global_aws_env" {
  name        = "global_aws_env"
  description = "Credenciales y configuración AWS compartida entre microservicios"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "global_aws_env_value" {
  secret_id = aws_secretsmanager_secret.global_aws_env.id
  secret_string = jsonencode({
    AWS_ACCESS_KEY_ID     = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
    AWS_REGION            = var.aws_region
  })
}

output "global_aws_secret_arn" {
  value       = aws_secretsmanager_secret.global_aws_env.arn
  description = "ARN del secret global con credenciales AWS"
}