output "db_loan_application_endpoint" {
  value = aws_db_instance.loan_application_db.address
}

output "loan_application_secrets_manager_arn" {
  value = aws_secretsmanager_secret.db_loan_application_secret.arn
}