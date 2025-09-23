# Networks
module "networks" {
  source = "./networks"

  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = var.tags 
}

# Security Groups
module "security" {
  source = "./security"

  vpc_id = module.networks.vpc_id
  tags   = var.tags
}

# RDS Instances
module "database_auth" {
  source = "./database/auth"

  vpc_id             = module.networks.vpc_id
  private_subnets    = module.networks.private_subnet_ids
  security_group_id  = module.security.rds_sg_id

  db_auth_identifier = var.db_auth_identifier
  db_auth_username   = var.db_auth_username
  instance_class     = var.instance_class
  tags               = var.tags
}

module "database_loan_application" {
  source = "./database/loan_application"

  vpc_id                        = module.networks.vpc_id
  private_subnets               = module.networks.private_subnet_ids
  security_group_id             = module.security.rds_sg_id

  db_loan_application_identifier = var.db_loan_application_identifier
  db_loan_application_username   = var.db_loan_application_username
  instance_class                 = var.instance_class
  tags                           = var.tags
}

# Dynamo DB Tables
module "dynamodb_reports" {
  source = "./dynamo"
}

# SQS Queues
module "calculate_capacity_queue" {
  source = "./sqs/calculate-capacity"
}

module "loan_decision_queue" {
  source = "./sqs/loan_decisions_queue"
}

module "update_loan_application" {
  source = "./sqs/update-loan-application"
}

module "update_reports" {
  source = "./sqs/update-reports"
}

# ECR Repositories
module "auth_service_ecr" {
  source = "./ecr/auth_service"
  aws_region = var.aws_region
  tags       = var.tags
}

module "loan_application_service_ecr" {
  source = "./ecr/loan_application_service"
  aws_region = var.aws_region
  tags       = var.tags
}

module "reports_service_ecr" {
  source = "./ecr/reports_service"
  aws_region = var.aws_region
  tags       = var.tags
}

# Task Definitions
module "auth_task_definition" {
  source = "./ecs/tasks/auth_service"
  tags = var.tags
  aws_region = var.aws_region
  auth_ecr_repository_url = module.auth_service_ecr.auth_service_repository_url
  db_auth_secret_arn = module.database_auth.auth_database_secrets_manager_arn
  db_auth_endpoint = module.database_auth.db_auth_endpoint
}
module "loan_application_task_definition" {
  source = "./ecs/tasks/loan_application_service"
  tags = var.tags
  aws_region = var.aws_region
  calculate_capacity_queue_url = module.calculate_capacity_queue.calculate_capacity_queue_url
  update_loan_application_queue_url = module.update_loan_application.update_loan_application_queue_url
  loan_decision_queue_url = module.loan_decision_queue.sqs_loan_decisions_queue_url
  update_reports_queue_url = module.update_reports.sqs_update_reports_queue_url
  db_loan_secret_arn = module.database_loan_application.loan_application_secrets_manager_arn
  global_aws_env_secret_arn = aws_secretsmanager_secret.global_aws_env.arn
  loan_application_ecr_repository_url = module.loan_application_service_ecr.loan_application_service_repository_url
  db_loan_endpoint = module.database_loan_application.db_loan_application_endpoint
  auth_service_url = module.auth_cluster.auth_service_url
}

module "reports_task_definition" {
  source = "./ecs/tasks/reports_service"
  tags = var.tags
  aws_region = var.aws_region
  update_reports_queue_url = module.update_reports.sqs_update_reports_queue_url
  reports_ecr_repository_url = module.reports_service_ecr.reports_service_repository_url
  global_aws_env_secret_arn = aws_secretsmanager_secret.global_aws_env.arn
  reports_dynamo_table_arn = module.dynamodb_reports.reports_table_arn
}

# Clusters
module "auth_cluster" {
  source = "./ecs/clusters/auth"
  tags   = var.tags
  vpc_id = module.networks.vpc_id
  private_subnets = module.networks.private_subnet_ids
  public_subnets = module.networks.public_subnet_ids
  auth_task_definition_arn = module.auth_task_definition.auth_task_definition_arn
}

module "loan_application_cluster" {
  source = "./ecs/clusters/loan_application"
  tags   = var.tags
  vpc_id = module.networks.vpc_id
  private_subnets = module.networks.private_subnet_ids
  public_subnets = module.networks.public_subnet_ids
  loan_application_task_definition_arn = module.loan_application_task_definition.loan_task_definition_arn
}

module "reports_cluster" {
  source = "./ecs/clusters/reports"
  tags   = var.tags
  vpc_id = module.networks.vpc_id
  private_subnets = module.networks.private_subnet_ids
  public_subnets = module.networks.public_subnet_ids
  reports_task_definition_arn = module.reports_task_definition.reports_task_definition_arn
}

# SES Configuration
module "ses_configuration" {
  source = "./ses"
}

# SNS Topics
module "topic_mail_sender_sns" {
  source = "./sns"
  tags = var.tags
}

# Lambda Functions
module "mail_sender_ses" {
  source = "./lambda/mail_sender_ses"
  notificaciones_creditos_topic_arn = module.topic_mail_sender_sns.notificaciones_creditos_topic_arn
}

module "mail_sender_sns" {
  source = "./lambda/mail_sender_sns"

  notificaciones_creditos_topic_arn = module.topic_mail_sender_sns.notificaciones_creditos_topic_arn
  calculate_capacity_queue_arn = module.calculate_capacity_queue.calculate_capacity_queue_arn
}

module "calculate_capacity" {
  source = "./lambda/calculate_capacity"

  input_queue_arn = module.calculate_capacity_queue.calculate_capacity_queue_arn
  output_queue_arn = module.update_loan_application.update_loan_application_queue_arn
  output_queue_url = module.update_loan_application.update_loan_application_queue_url
}

module "daily_report" {
  source = "./lambda/daily_report"
}

#API Gateway
module "api_gateway" {
  source = "./api_gateway"
  auth_alb = module.auth_cluster.auth_service_url
  loan_alb = module.loan_application_cluster.loan_application_service_url
  reports_alb = module.reports_cluster.reports_service_url
}