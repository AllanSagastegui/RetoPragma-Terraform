resource "aws_cloudwatch_log_group" "loan_service" {
  name              = "loan-application-service-terraform"
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_ecs_task_definition" "loan_task_def" {
  family                   = var.task_definition_family_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "3072"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.loan_task_role.arn

  container_definitions = jsonencode([
    {
      name      = var.task_definition_name
      image     = "${var.loan_application_ecr_repository_url}:latest"
      essential = true

      secrets = [
        { name = "AUTH_SERVICE_URL", valueFrom = "${aws_secretsmanager_secret.loan_service_envs.arn}:AUTH_SERVICE_URL::" },
        { name = "AWS_ACCESS_KEY_ID", valueFrom = "${var.global_aws_env_secret_arn}:AWS_ACCESS_KEY_ID::" },
        { name = "AWS_SECRET_ACCESS_KEY", valueFrom = "${var.global_aws_env_secret_arn}:AWS_SECRET_ACCESS_KEY::" },
        { name = "AWS_REGION", valueFrom = "${var.global_aws_env_secret_arn}:AWS_REGION::" },
        { name = "AWS_QUEUE_CALCULATE_URL", valueFrom = "${aws_secretsmanager_secret.loan_service_envs.arn}:AWS_QUEUE_CALCULATE_URL::" },
        { name = "AWS_QUEUE_CALCULATE_RESPONSE_URL", valueFrom = "${aws_secretsmanager_secret.loan_service_envs.arn}:AWS_QUEUE_CALCULATE_RESPONSE_URL::" },
        { name = "AWS_QUEUE_REPORTS", valueFrom = "${aws_secretsmanager_secret.loan_service_envs.arn}:AWS_QUEUE_REPORTS::" },
        { name = "AWS_QUEUE_URL", valueFrom = "${aws_secretsmanager_secret.loan_service_envs.arn}:AWS_QUEUE_URL::" },
        { name = "LOAN_DB_HOST", valueFrom = "${aws_secretsmanager_secret.loan_service_envs.arn}:LOAN_DB_HOST::" },
        { name = "LOAN_DB_NAME", valueFrom = "${aws_secretsmanager_secret.loan_service_envs.arn}:LOAN_DB_NAME::" },
        { name = "LOAN_DB_PORT", valueFrom = "${aws_secretsmanager_secret.loan_service_envs.arn}:LOAN_DB_PORT::" },
        { name = "LOAN_DB_USER", valueFrom = "${var.db_loan_secret_arn}:username::" },
        { name = "LOAN_DB_PASSWORD", valueFrom = "${var.db_loan_secret_arn}:password::" }
      ]

      portMappings = [
        { containerPort = 8090, hostPort = 8090, protocol = "tcp" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.loan_service.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ECS - Terraform - Loan Service"
        }
      }
    }
  ])
}