resource "aws_secretsmanager_secret" "loan_service_envs" {
  name        = "loan_service_envs"
  description = "Variables de entorno del Loan Application Service"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "loan_service_envs_value" {
  secret_id = aws_secretsmanager_secret.loan_service_envs.id
  secret_string = jsonencode({
    AUTH_SERVICE_URL              = var.auth_service_url
    AWS_QUEUE_CALCULATE_URL       = var.calculate_capacity_queue_url
    AWS_QUEUE_CALCULATE_RESPONSE_URL = var.update_loan_application_queue_url
    AWS_QUEUE_REPORTS             = var.update_reports_queue_url
    AWS_QUEUE_URL                 = var.loan_decision_queue_url
    LOAN_DB_HOST                  = var.db_loan_endpoint
    LOAN_DB_NAME                  = "loan_pragma"
    LOAN_DB_PORT                  = "5432"
  })
}