resource "aws_ecr_repository" "loan_application_service" {
  name = "pragma/loan-application-service"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

resource "null_resource" "push_loan_service" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --region ${var.aws_region} \
        | docker login --username AWS --password-stdin ${aws_ecr_repository.loan_application_service.repository_url}

      docker tag 1ff571b90576:latest ${aws_ecr_repository.loan_application_service.repository_url}:latest

      docker push ${aws_ecr_repository.loan_application_service.repository_url}:latest
    EOT
  }

  depends_on = [aws_ecr_repository.loan_application_service]
}