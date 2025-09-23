resource "aws_sqs_queue" "loan_decisions_queue" {
  name                       = "loan-decisions-queue"
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 30

  sqs_managed_sse_enabled = true
}

resource "aws_iam_role" "sqs_loan_decisions_role" {
  name = "sqs-loan-decisions-role"

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

resource "aws_iam_policy" "sqs_loan_decisions_policy" {
  name        = "sqs-loan-decisions-policy"
  description = "Permite enviar y recibir mensajes en la cola loan-decisions-queue"

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
        Resource = aws_sqs_queue.loan_decisions_queue.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sqs_loan_decisions_attach" {
  role       = aws_iam_role.sqs_loan_decisions_role.name
  policy_arn = aws_iam_policy.sqs_loan_decisions_policy.arn
}

output "sqs_loan_decisions_queue_arn" {
  description = "ARN de la cola loan-decisions-queue"
  value       = aws_sqs_queue.loan_decisions_queue.arn
}

output "sqs_loan_decisions_queue_url" {
  description = "URL de la cola loan-decisions-queue"
  value       = aws_sqs_queue.loan_decisions_queue.url
}