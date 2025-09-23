resource "aws_ecr_repository" "auth_service" {
  name = "pragma/auth-service"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

resource "null_resource" "push_auth_service" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --region ${var.aws_region} \
        | docker login --username AWS --password-stdin ${aws_ecr_repository.auth_service.repository_url}

      docker tag cf17b7b4dbdc:latest ${aws_ecr_repository.auth_service.repository_url}:latest

      docker push ${aws_ecr_repository.auth_service.repository_url}:latest
    EOT
  }

  depends_on = [aws_ecr_repository.auth_service]
}