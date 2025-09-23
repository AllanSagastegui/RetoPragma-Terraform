resource "aws_ecs_cluster" "auth_service_cluster" {
  name = "auth-service-cluster"
  tags = var.tags
}

resource "aws_security_group" "auth_lb_sg" {
  name   = "auth-lb-sg"
  vpc_id = var.vpc_id
  tags   = var.tags

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "auth_alb" {
  name               = "auth-service-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.auth_lb_sg.id]
  subnets            = var.public_subnets
  tags               = var.tags
}

resource "aws_lb_target_group" "auth_tg" {
  name        = "auth-service-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags        = var.tags

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "auth_listener" {
  load_balancer_arn = aws_lb.auth_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth_tg.arn
  }
}

resource "aws_security_group" "auth_service_sg" {
  name   = "auth-service-sg"
  vpc_id = var.vpc_id
  tags   = var.tags

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.auth_lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "auth_service" {
  name            = "auth-service"
  cluster         = aws_ecs_cluster.auth_service_cluster.id
  task_definition = var.auth_task_definition_arn
  desired_count   = 1
  launch_type     = "FARGATE"
  tags            = var.tags

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.auth_service_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.auth_tg.arn
    container_name   = "auth-service"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.auth_listener]
}