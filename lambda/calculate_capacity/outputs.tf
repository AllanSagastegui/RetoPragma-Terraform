output "calculate_capacity_lambda_arn" {
  description = "ARN del Lambda calculate-capacity"
  value       = aws_lambda_function.calculate_capacity.arn
}

output "calculate_capacity_lambda_name" {
  description = "Nombre del Lambda calculate-capacity"
  value       = aws_lambda_function.calculate_capacity.function_name
}
