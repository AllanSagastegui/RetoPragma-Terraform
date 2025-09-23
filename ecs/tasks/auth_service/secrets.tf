resource "aws_secretsmanager_secret" "auth_service_envs" {
  name        = "auth_service_envs"
  description = "Variables de entorno del Auth Service"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "auth_service_envs_value" {
  secret_id = aws_secretsmanager_secret.auth_service_envs.id
  secret_string = jsonencode({
    AUTH_DB_HOST = var.db_auth_endpoint
    AUTH_DB_NAME = "auth_pragma"
    AUTH_DB_PORT = "5432"
  })
}