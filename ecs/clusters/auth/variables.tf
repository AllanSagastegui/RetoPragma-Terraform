variable "tags" {
  description = "A map of tags to assign to the resources."
}

variable "private_subnets" {
  description = "List of private subnet IDs for the ECS service."
}

variable "public_subnets" {
  description = "List of public subnet IDs for the ALB."
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID where the ECS service will be deployed."
}

variable "auth_task_definition_arn" {
  description = "ARN del Task Definition del Auth Service"
  type        = string
}