variable "vpc_id" {}
variable "private_subnets" { type = list(string) }
variable "security_group_id" {}
variable "db_loan_application_identifier" {}
variable "db_loan_application_username" {}
variable "instance_class" {}
variable "tags" { type = map(string) }