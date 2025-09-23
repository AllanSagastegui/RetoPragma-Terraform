resource "random_password" "db_auth_password" {
  length  = 20
  special = true
}

resource "aws_secretsmanager_secret" "db_auth_secret" {
  name        = "db_auth_secret_credentials"
  description = "Credenciales de la base de datos ${var.db_auth_identifier}"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "db_auth_secret_value" {
  secret_id     = aws_secretsmanager_secret.db_auth_secret.id
  secret_string = jsonencode({
    username = var.db_auth_username
    password = random_password.db_auth_password.result
    engine   = "postgres"
    host     = ""
    port     = 5432
    dbname   = "auth_pragma"
  })
}

resource "aws_db_subnet_group" "auth_db_subnet_group" {
  name       = "${var.db_auth_identifier}-subnet-group"
  subnet_ids = var.private_subnets
  tags       = var.tags
}

resource "aws_db_instance" "auth_db" {
  identifier              = var.db_auth_identifier
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "17.5"
  instance_class          = var.instance_class
  db_name                 = "auth_pragma"
  username                = var.db_auth_username
  password                = random_password.db_auth_password.result
  db_subnet_group_name    = aws_db_subnet_group.auth_db_subnet_group.name
  vpc_security_group_ids  = [var.security_group_id]
  publicly_accessible     = true
  skip_final_snapshot     = true
  backup_retention_period = 7
  deletion_protection     = false
  apply_immediately       = true
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "db_auth_secret_final" {
  secret_id = aws_secretsmanager_secret.db_auth_secret.id
  secret_string = jsonencode({
    username = var.db_auth_username
    password = random_password.db_auth_password.result
    engine   = "postgres"
    host     = aws_db_instance.auth_db.address
    port     = 5432
    dbname   = "auth_pragma"
  })
  depends_on = [aws_db_instance.auth_db]
}