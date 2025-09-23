resource "aws_sqs_queue" "update_loan_application" {
  name                       = "update-loan-application"
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 30

  sqs_managed_sse_enabled = true
}

resource "aws_iam_role" "sqs_update_loan_application_role" {
  name = "sqs-update-loan-application-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "sqs_update_loan_application_policy" {
  name        = "sqs-update-loan-application-policy"
  description = "Permite enviar y recibir mensajes en la cola update-loan-application"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.update_loan_application.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sqs_update_loan_application_attach" {
  role       = aws_iam_role.sqs_update_loan_application_role.name
  policy_arn = aws_iam_policy.sqs_update_loan_application_policy.arn
}

output "update_loan_application_queue_arn" {
  description = "ARN de la cola update-loan-application"
  value       = aws_sqs_queue.update_loan_application.arn
}

output "update_loan_application_queue_url" {
  description = "URL de la cola update-loan-application"
  value       = aws_sqs_queue.update_loan_application.id
}