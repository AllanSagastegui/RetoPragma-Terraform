resource "aws_iam_role" "ecs_task_execution_role" {
  name = "reports-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "reports_task_role" {
  name = "reports-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "reports_service_secrets_policy" {
  name        = "reports-service-secrets-policy"
  description = "Permite a Reports Service leer sus secrets de envs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = aws_secretsmanager_secret.reports_service_envs.arn
    }]
  })
}

resource "aws_iam_policy" "reports_logs_policy" {
  name        = "reports-logs-policy"
  description = "Permite a Reports Service escribir logs en CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_policy" "reports_dynamo_policy" {
  name        = "reports-dynamo-policy"
  description = "Permite a Reports Service realizar CRUD sobre la tabla Reports"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = var.reports_dynamo_table_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "reports_service_secrets_attach" {
  role       = aws_iam_role.reports_task_role.name
  policy_arn = aws_iam_policy.reports_service_secrets_policy.arn
}

resource "aws_iam_role_policy_attachment" "reports_logs_attach" {
  role       = aws_iam_role.reports_task_role.name
  policy_arn = aws_iam_policy.reports_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "reports_dynamo_attach" {
  role       = aws_iam_role.reports_task_role.name
  policy_arn = aws_iam_policy.reports_dynamo_policy.arn
}