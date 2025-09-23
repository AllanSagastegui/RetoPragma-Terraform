resource "aws_sqs_queue" "calculate_capacity" {
  name                       = "calculate-capacity"
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 30

  sqs_managed_sse_enabled = true
}

resource "aws_iam_role" "sqs_consumer_role" {
  name = "sqs-calculate-capacity-role"

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

resource "aws_iam_policy" "sqs_calculate_capacity_policy" {
  name        = "sqs-calculate-capacity-policy"
  description = "Permite enviar y recibir mensajes en la cola calculate-capacity"

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
        Resource = aws_sqs_queue.calculate_capacity.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sqs_calculate_capacity_attach" {
  role       = aws_iam_role.sqs_consumer_role.name
  policy_arn = aws_iam_policy.sqs_calculate_capacity_policy.arn
}

output "calculate_capacity_queue_url" {
  value       = aws_sqs_queue.calculate_capacity.id
  description = "URL de la SQS Queue para calcular la capacidad"
}

output "calculate_capacity_queue_arn" {
  value       = aws_sqs_queue.calculate_capacity.arn
  description = "ARN de la SQS Queue para calcular la capacidad"
}
