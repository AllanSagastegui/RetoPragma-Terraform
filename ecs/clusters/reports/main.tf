resource "aws_ecs_cluster" "reports_service_cluster" {
  name = "reports-service-cluster"
  tags = var.tags
}

resource "aws_security_group" "reports_lb_sg" {
  name   = "reports-lb-sg"
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

resource "aws_security_group" "reports_service_sg" {
  name   = "reports-service-sg"
  vpc_id = var.vpc_id
  tags   = var.tags

  ingress {
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    security_groups = [aws_security_group.reports_lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "reports_alb" {
  name               = "reports-service-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.reports_lb_sg.id]
  subnets            = var.public_subnets
  tags               = var.tags
}

resource "aws_lb_target_group" "reports_tg" {
  name        = "reports-service-tg"
  port        = 9090
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags        = var.tags

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "reports_listener" {
  load_balancer_arn = aws_lb.reports_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.reports_tg.arn
  }
}

resource "aws_ecs_service" "reports_service" {
  name            = "reports-service"
  cluster         = aws_ecs_cluster.reports_service_cluster.id
  task_definition = var.reports_task_definition_arn
  desired_count   = 1
  launch_type     = "FARGATE"
  tags            = var.tags

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.reports_service_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.reports_tg.arn
    container_name   = "reports-service"
    container_port   = 9090
  }

  depends_on = [aws_lb_listener.reports_listener]
}