resource "aws_iam_role" "ecs_task_execution_role" {
  name = "loan-task-execution-role"

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

resource "aws_iam_role" "loan_task_role" {
  name = "loan-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "loan_service_secrets_policy" {
  name        = "loan-service-secrets-policy"
  description = "Permite a Loan Service leer sus secrets de envs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = aws_secretsmanager_secret.loan_service_envs.arn
    }]
  })
}

resource "aws_iam_policy" "loan_logs_policy" {
  name        = "loan-logs-policy"
  description = "Permite a Loan Service escribir logs en CloudWatch"

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

resource "aws_iam_role_policy_attachment" "loan_service_secrets_attach" {
  role       = aws_iam_role.loan_task_role.name
  policy_arn = aws_iam_policy.loan_service_secrets_policy.arn
}

resource "aws_iam_role_policy_attachment" "loan_logs_attach" {
  role       = aws_iam_role.loan_task_role.name
  policy_arn = aws_iam_policy.loan_logs_policy.arn
}