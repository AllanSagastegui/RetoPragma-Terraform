resource "aws_iam_role" "lambda_exec" {
  name = "lambda-sns-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_sqs_sns_policy" {
  name   = "lambda-sqs-sns-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["sns:Publish"],
        Resource = var.notificaciones_creditos_topic_arn
      },
      {
        Effect   = "Allow",
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = var.calculate_capacity_queue_arn
      },
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_sqs_sns_policy.arn
}

resource "aws_lambda_function" "pragma_mail_sender_sns" {
  function_name    = "PragmaMailSenderSNS"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"

  filename         = "${path.module}/pragmaMailSenderSNS.zip"
  source_code_hash = filebase64sha256("${path.module}/pragmaMailSenderSNS.zip")

  environment {
    variables = {
      TOPIC_ARN = var.notificaciones_creditos_topic_arn
    }
  }
}

resource "aws_lambda_event_source_mapping" "pragma_mail_sqs_trigger" {
  event_source_arn = var.calculate_capacity_queue_arn
  function_name    = aws_lambda_function.pragma_mail_sender_sns.arn
  batch_size       = 10
  enabled          = true
}
