variable "input_queue_arn" {
  description = "ARN de la cola de entrada (calculate-capacity)"
  type        = string
}

variable "output_queue_arn" {
  description = "ARN de la cola de salida (OUTPUT_QUEUE)"
  type        = string
}

variable "output_queue_url" {
  description = "URL de la cola de salida (OUTPUT_QUEUE)"
  type        = string
}
