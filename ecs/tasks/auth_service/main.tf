resource "aws_cloudwatch_log_group" "auth_service" {
  name              = "auth-service-terraform"
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_ecs_task_definition" "auth_service" {
  family                   = "auth-service-def-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "3072"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.auth_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "auth-service"
      image     = var.auth_ecr_repository_url
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp" 
        }
      ]
      environment = [
        {
          name  = "AUTH_DB_HOST"
          valueFrom = "${aws_secretsmanager_secret.auth_service_envs.arn}:AUTH_DB_HOST::"
        },
        {
          name  = "AUTH_DB_NAME"
          valueFrom = "${aws_secretsmanager_secret.auth_service_envs.arn}:AUTH_DB_NAME::"
        },
        {
          name  = "AUTH_DB_PORT"
          valueFrom = "${aws_secretsmanager_secret.auth_service_envs.arn}:AUTH_DB_PORT::"
        }
      ]
      secrets = [
        {
          name      = "AUTH_DB_USER"
          valueFrom = "${var.db_auth_secret_arn}:username::"
        },
        {
          name      = "AUTH_DB_PASSWORD"
          valueFrom = "${var.db_auth_secret_arn}:password::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.auth_service.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ECS - Terraform - Auth Service"
        }
      }
    }
  ])
}