resource "aws_iam_role" "lambda_role" {
  name = "pragmaMailSenderSES-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_ses_policy" {
  name        = "pragmaMailSenderSES-policy"
  description = "Permite a la Lambda enviar correos usando SES y escribir en CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["ses:SendTemplatedEmail"],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_ses_policy.arn
}

resource "aws_lambda_function" "pragma_mail_sender_ses" {
  function_name = "pragmaMailSenderSES"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"

  filename         = "${path.module}/pragmaMailSenderSES.zip"
  source_code_hash = filebase64sha256("${path.module}/pragmaMailSenderSES.zip")

  environment {
    variables = {
      TEMPLATE_NAME = "NotificacionCredito"
    }
  }

  timeout     = 30
  memory_size = 256
}

resource "aws_sns_topic_subscription" "sns_to_lambda" {
  topic_arn = var.notificaciones_creditos_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.pragma_mail_sender_ses.arn
}

resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pragma_mail_sender_ses.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.notificaciones_creditos_topic_arn
}