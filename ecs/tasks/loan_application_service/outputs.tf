output "loan_task_definition_arn" {
  description = "ARN del ECS Task Definition de Loan Application Service"
  value       = aws_ecs_task_definition.loan_task_def.arn
}