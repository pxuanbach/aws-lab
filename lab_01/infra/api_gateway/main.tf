resource "aws_iam_role" "api_gateway_sqs_role" {
  name = "api-gateway-sqs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "api_gateway_sqs_policy" {
  name = "api-gateway-sqs-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:SendMessage",
        ]
        Resource = var.sqs_queue.arn
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_sqs_attachment" {
  role = aws_iam_role.api_gateway_sqs_role.name
  policy_arn = aws_iam_policy.api_gateway_sqs_policy.arn
}

resource "aws_api_gateway_rest_api" "test_api" {
  name = "test-api"
}

resource "aws_api_gateway_resource" "test_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  parent_id = aws_api_gateway_rest_api.test_api.root_resource_id
  path_part = var.rest_api.path
}

resource "aws_api_gateway_method" "test_api_write_method" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  resource_id = aws_api_gateway_resource.test_api_resource.id
  http_method = var.rest_api.method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "test_api_sqs_integration" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  resource_id = aws_api_gateway_resource.test_api_resource.id
  http_method = aws_api_gateway_method.test_api_write_method.http_method
  integration_http_method = "POST"
  type = "AWS"
  uri = "arn:aws:apigateway:${data.aws_region.current.name}:sqs:path/${var.sqs_queue.name}"
  credentials = aws_iam_role.api_gateway_sqs_role.arn

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$input.body"
  }
}

resource "aws_api_gateway_method_response" "test_api_response_200" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  resource_id = aws_api_gateway_resource.test_api_resource.id
  http_method = aws_api_gateway_method.test_api_write_method.http_method
  status_code = "200"

  # cors
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true,
  }
}

resource "aws_api_gateway_integration_response" "test_api_sqs_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  resource_id = aws_api_gateway_resource.test_api_resource.id
  http_method = aws_api_gateway_method.test_api_write_method.http_method
  status_code = aws_api_gateway_method_response.test_api_response_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
    "method.response.header.Access-Control-Allow-Methods" = "'POST'",
    "method.response.header.Access-Control-Allow-Origin" = var.api_gateway_cors_origin
  }

  depends_on = [
    aws_api_gateway_method.test_api_write_method,
    aws_api_gateway_integration.test_api_sqs_integration
  ]
}

resource "aws_api_gateway_deployment" "test_api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  stage_name = var.stage_name
  depends_on = [ aws_api_gateway_integration.test_api_sqs_integration ]
}
