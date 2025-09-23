resource "aws_sns_topic" "notificaciones_creditos" {
  name = "NotificacionesCreditos"

  tags = merge(var.tags, {
    Service = "SNS"
  })
}

output "notificaciones_creditos_topic_arn" {
  value       = aws_sns_topic.notificaciones_creditos.arn
  description = "ARN del SNS Topic para notificaciones de créditos"
}
