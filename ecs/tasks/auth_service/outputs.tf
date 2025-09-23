output "auth_task_definition_arn" {
  description = "ARN del Task Definition del Auth Service"
  value       = aws_ecs_task_definition.auth_service.arn
}