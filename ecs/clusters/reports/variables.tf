variable "vpc_id" {
  description = "The VPC ID where the ECS service will be deployed."
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for the ALB."
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs for the ECS service."
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "reports_task_definition_arn" {
  description = "ARN del ECS Task Definition a usar en el servicio"
  type        = string
}
