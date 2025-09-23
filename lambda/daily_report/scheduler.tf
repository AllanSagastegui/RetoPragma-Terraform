resource "aws_scheduler_schedule" "update_reports_schedule" {
  name        = "update-reports-daily-8pm"
  description = "Ejecuta la lambda update-reports todos los días a las 8pm Lima"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 20 * * ? *)"
  schedule_expression_timezone = "America/Lima"

  target {
    arn      = aws_lambda_function.update_reports.arn
    role_arn = aws_iam_role.update_reports_scheduler_role.arn
  }
}

resource "aws_iam_role" "update_reports_scheduler_role" {
  name = "update-reports-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "scheduler.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "update_reports_scheduler_policy" {
  name = "update-reports-scheduler-policy"

  role = aws_iam_role.update_reports_scheduler_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "lambda:InvokeFunction",
        Resource = aws_lambda_function.update_reports.arn
      }
    ]
  })
}