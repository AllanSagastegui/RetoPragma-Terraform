resource "aws_secretsmanager_secret" "reports_service_envs" {
  name        = "reports_service_envs"
  description = "Variables de entorno del Reports Service"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "reports_service_envs_value" {
  secret_id = aws_secretsmanager_secret.reports_service_envs.id
  secret_string = jsonencode({
    AWS_QUEUE_REPORTS     = var.update_reports_queue_url
  })
}