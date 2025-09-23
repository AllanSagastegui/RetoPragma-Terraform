variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "db_auth_identifier" {
  description = "Identifier for the auth DB instance"
  type        = string
}

variable "db_auth_username" {
  description = "Master username for the auth DB"
  type        = string
}

variable "db_loan_application_identifier" {
  description = "Identifier for the loan application DB instance"
  type        = string
}

variable "db_loan_application_username" {
  description = "Master username for the loan application DB"
  type        = string
}

variable "instance_class" {
  description = "Instance class for RDS instances"
  type        = string
  default     = "db.t3.micro"
}

variable "aws_access_key_id" {
  description = "Access Key de AWS"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "Secret Key de AWS"
  type        = string
  sensitive   = true
}