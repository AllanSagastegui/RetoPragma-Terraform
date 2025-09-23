data "aws_caller_identity" "current" {}

resource "aws_iam_role" "update_reports_role" {
  name = "update-reports-role"

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

resource "aws_iam_policy" "update_reports_policy" {
  name        = "update-reports-policy"
  description = "Permite al Lambda leer DynamoDB, enviar correos SES y escribir logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:Scan",
          "dynamodb:GetItem"
        ],
        Resource = "arn:aws:dynamodb:us-east-1:${data.aws_caller_identity.current.account_id}:table/Reports"
      },
      {
        Effect   = "Allow",
        Action   = [
          "ses:SendTemplatedEmail"
        ],
        Resource = "*"
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

resource "aws_iam_role_policy_attachment" "update_reports_policy_attach" {
  role       = aws_iam_role.update_reports_role.name
  policy_arn = aws_iam_policy.update_reports_policy.arn
}

resource "aws_lambda_function" "update_reports" {
  function_name = "update-reports"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  role          = aws_iam_role.update_reports_role.arn

  filename         = "${path.module}/dailyReport.zip"
  source_code_hash = filebase64sha256("${path.module}/dailyReport.zip")

  environment {
    variables = {
      TEMPLATE_NAME = "Reporte-Diario-Solicitudes"
    }
  }

  timeout     = 60
  memory_size = 256
}