variable "vpc_id" {}
variable "private_subnets" { type = list(string) }
variable "security_group_id" {}
variable "db_auth_identifier" {}
variable "db_auth_username" {}
variable "instance_class" {}
variable "tags" { type = map(string) }