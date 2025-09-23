resource "aws_apigatewayv2_api" "crediya_api_gateway" {
  name          = "crediya_api_gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "auth_integration" {
  api_id                 = aws_apigatewayv2_api.crediya_api_gateway.id
  integration_type       = "HTTP_PROXY"
  integration_uri        = var.auth_alb
  integration_method     = "ANY"
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_integration" "loan_integration" {
  api_id                 = aws_apigatewayv2_api.crediya_api_gateway.id
  integration_type       = "HTTP_PROXY"
  integration_uri        = var.loan_alb
  integration_method     = "ANY"
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_integration" "reports_integration" {
  api_id                 = aws_apigatewayv2_api.crediya_api_gateway.id
  integration_type       = "HTTP_PROXY"
  integration_uri        = var.reports_alb
  integration_method     = "ANY"
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "auth_route" {
  api_id    = aws_apigatewayv2_api.crediya_api_gateway.id
  route_key = "ANY /auth/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.auth_integration.id}"
}

resource "aws_apigatewayv2_route" "loan_route" {
  api_id    = aws_apigatewayv2_api.crediya_api_gateway.id
  route_key = "ANY /loan/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.loan_integration.id}"
}

resource "aws_apigatewayv2_route" "reports_route" {
  api_id    = aws_apigatewayv2_api.crediya_api_gateway.id
  route_key = "ANY /reports/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.reports_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.crediya_api_gateway.id
  name        = "$default"
  auto_deploy = true
}

output "microservices_api_url" {
  description = "URL pública para acceder a los microservicios vía API Gateway"
  value       = aws_apigatewayv2_stage.default_stage.invoke_url
}