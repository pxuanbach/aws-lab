variable "aws_region" {
  type = string
  description = "AWS region"
  default = "ap-southeast-1"
}

variable "aws_profile" {
  type = string
  description = "AWS profile"
  default = "default"
}

variable "env" {
  type = string
  description = "Environment"
  default = "dev"
}

variable "api_gateway_cors_origin" {
  type = string
  description = "API Gateway CORS"
  default = "'*'"
}
