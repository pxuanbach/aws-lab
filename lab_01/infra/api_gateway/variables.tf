variable "rest_api" {
  type = object({
    path = string
    method = string
  })
  description = "RESTful API"
  default = {
    method = "POST"
    path = "test"
  }
}

variable "sqs_queue" {}

variable "api_gateway_cors_origin" {
  type = string
  default = "'*'"
}

variable "stage_name" {
  type = string
  default = "dev"
}
