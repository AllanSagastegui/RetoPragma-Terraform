resource "aws_iam_role" "ecs_task_execution_role" {
  name = "auth-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "auth_task_role" {
  name = "auth-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "auth_secrets_policy" {
  name        = "auth-secrets-policy"
  description = "Permite a Auth Service leer secretos de Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = [ var.db_auth_secret_arn,
                  aws_secretsmanager_secret.auth_service_envs.arn 
                ]
    }]
  })
}

resource "aws_iam_policy" "auth_logs_policy" {
  name        = "auth-logs-policy"
  description = "Permite a Auth Service escribir logs en CloudWatch"

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

resource "aws_iam_role_policy_attachment" "auth_task_secrets_attach" {
  role       = aws_iam_role.auth_task_role.name
  policy_arn = aws_iam_policy.auth_secrets_policy.arn
}

resource "aws_iam_role_policy_attachment" "auth_task_logs_attach" {
  role       = aws_iam_role.auth_task_role.name
  policy_arn = aws_iam_policy.auth_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_execution_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_secrets_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.auth_secrets_policy.arn
}