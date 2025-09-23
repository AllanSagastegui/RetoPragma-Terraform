resource "random_password" "db_loan_application_password" {
  length  = 20
  special = true
}

resource "aws_secretsmanager_secret" "db_loan_application_secret" {
  name        = "db_loan_application_secret_credentials"
  description = "Credenciales de la base de datos ${var.db_loan_application_identifier}"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "db_loan_secret_value" {
  secret_id     = aws_secretsmanager_secret.db_loan_application_secret.id
  secret_string = jsonencode({
    username = var.db_loan_application_username
    password = random_password.db_loan_application_password.result
    engine   = "postgres"
    host     = ""
    port     = 5432
    dbname   = "loan_application_pragma"
  })
}

resource "aws_db_subnet_group" "loan_db_subnet_group" {
  name       = "${var.db_loan_application_identifier}-subnet-group"
  subnet_ids = var.private_subnets
  tags       = var.tags
}

resource "aws_db_instance" "loan_application_db" {
  identifier              = var.db_loan_application_identifier
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "17.5"
  instance_class          = var.instance_class
  db_name                 = "loan_application_pragma"
  username                = var.db_loan_application_username
  password                = random_password.db_loan_application_password.result
  db_subnet_group_name    = aws_db_subnet_group.loan_db_subnet_group.name
  vpc_security_group_ids  = [var.security_group_id]
  publicly_accessible     = true
  skip_final_snapshot     = true
  backup_retention_period = 7
  deletion_protection     = false
  apply_immediately       = true
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "db_loan_secret_final" {
  secret_id = aws_secretsmanager_secret.db_loan_application_secret.id
  secret_string = jsonencode({
    username = var.db_loan_application_username
    password = random_password.db_loan_application_password.result
    engine   = "postgres"
    host     = aws_db_instance.loan_application_db.address
    port     = 5432
    dbname   = "loan_application_pragma"
  })
  depends_on = [aws_db_instance.loan_application_db]
}