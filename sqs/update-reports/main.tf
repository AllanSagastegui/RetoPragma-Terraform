resource "aws_sqs_queue" "update_reports" {
  name                       = "update-reports"
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 30

  sqs_managed_sse_enabled = true
}

resource "aws_iam_role" "sqs_update_reports_role" {
  name = "sqs-update-reports-role"

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

resource "aws_iam_policy" "sqs_update_reports_policy" {
  name        = "sqs-update-reports-policy"
  description = "Permite enviar y recibir mensajes en la cola update-reports"

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
        Resource = aws_sqs_queue.update_reports.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sqs_update_reports_attach" {
  role       = aws_iam_role.sqs_update_reports_role.name
  policy_arn = aws_iam_policy.sqs_update_reports_policy.arn
}

output "sqs_update_reports_queue_arn" {
  description = "ARN de la cola update-reports"
  value       = aws_sqs_queue.update_reports.arn
}

output "sqs_update_reports_queue_url" {
  description = "URL de la cola update-reports"
  value       = aws_sqs_queue.update_reports.url
}