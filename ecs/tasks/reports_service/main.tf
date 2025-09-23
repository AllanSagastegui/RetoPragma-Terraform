resource "aws_cloudwatch_log_group" "reports_service" {
  name              = "reports-service-terraform"
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_ecs_task_definition" "reports_task_def" {
  family                   = "reports-service-def-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "3072"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.reports_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "reports-service"
      image     = "${var.reports_ecr_repository_url}:latest"
      essential = true

      secrets = [
        {
          name      = "AWS_ACCESS_KEY_ID"
          valueFrom = "${var.global_aws_env_secret_arn}:AWS_ACCESS_KEY_ID::"
        },
        {
          name      = "AWS_SECRET_ACCESS_KEY"
          valueFrom = "${var.global_aws_env_secret_arn}:AWS_SECRET_ACCESS_KEY::"
        },
        {
          name      = "AWS_REGION"
          valueFrom = "${var.global_aws_env_secret_arn}:AWS_REGION::"
        },
        {
          name      = "AWS_QUEUE_REPORTS"
          valueFrom = "${aws_secretsmanager_secret.reports_service_envs.arn}:AWS_QUEUE_REPORTS::"
        }
      ] 

      portMappings = [
        { containerPort = 9090, hostPort = 9090, protocol = "tcp" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.reports_service.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ECS - Terraform - Reports Service"
        }
      }
    }
  ])
}