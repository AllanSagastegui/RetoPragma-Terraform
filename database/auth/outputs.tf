output "db_auth_endpoint" {
  value = aws_db_instance.auth_db.address
}

output "auth_database_secrets_manager_arn" {
  value = aws_secretsmanager_secret.db_auth_secret.arn
}