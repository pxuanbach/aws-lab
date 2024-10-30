terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # version = ">= 5.72.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # profile = var.aws_profile
}


module "sqs_queue" {
  source = "./infra/sqs"
  queue_name = "test-queue"
}

module "api_gateway" {
  source = "./infra/api_gateway"

  stage_name = var.env
  sqs_queue = module.sqs_queue.test_queue
  api_gateway_cors_origin = var.api_gateway_cors_origin
}

module "dynamodb" {
  source = "./infra/dynamodb"
}

module "lambda" {
  source = "./infra/lambda"

  dynamodb_table = module.dynamodb.test_table
  sqs_queue = module.sqs_queue.test_queue
}

output "api_url" {
  value = module.api_gateway.test_api_url
}
