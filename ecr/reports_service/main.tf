resource "aws_ecr_repository" "reports_service" {
  name = "pragma/reports-service"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

resource "null_resource" "push_reports_service" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --region ${var.aws_region} \
        | docker login --username AWS --password-stdin ${aws_ecr_repository.reports_service.repository_url}

      docker tag a7bf4b6a8d3c:latest ${aws_ecr_repository.reports_service.repository_url}:latest

      docker push ${aws_ecr_repository.reports_service.repository_url}:latest
    EOT
  }

  depends_on = [aws_ecr_repository.reports_service]
}