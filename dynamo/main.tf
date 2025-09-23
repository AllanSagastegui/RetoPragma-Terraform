resource "aws_dynamodb_table" "reports" {
  name         = "Reports"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = "prod"
    Service     = "loan-reports"
  }
}

output "reports_table_arn" {
  value       = aws_dynamodb_table.reports.arn
  description = "ARN de la tabla DynamoDB Reports"
}