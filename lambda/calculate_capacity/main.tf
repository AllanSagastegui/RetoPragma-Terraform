resource "aws_iam_role" "lambda_capacity_role" {
  name = "calculate-capacity-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_capacity_policy" {
  name        = "calculate-capacity-policy"
  description = "Permisos mínimos para Lambda que procesa capacidad crediticia"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = var.input_queue_arn
      },
      {
        Effect   = "Allow",
        Action   = [
          "sqs:SendMessage"
        ],
        Resource = var.output_queue_arn
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_capacity_policy_attach" {
  role       = aws_iam_role.lambda_capacity_role.name
  policy_arn = aws_iam_policy.lambda_capacity_policy.arn
}

resource "aws_lambda_function" "calculate_capacity" {
  function_name = "calculate-capacity"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_capacity_role.arn

  filename         = "${path.module}/pragmaCalculateCapacity.zip"
  source_code_hash = filebase64sha256("${path.module}/pragmaCalculateCapacity.zip")

  environment {
    variables = {
      OUTPUT_QUEUE_URL = var.output_queue_url
    }
  }

  timeout     = 30
  memory_size = 256
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = var.input_queue_arn
  function_name    = aws_lambda_function.calculate_capacity.arn
  batch_size       = 10
  enabled          = true
}