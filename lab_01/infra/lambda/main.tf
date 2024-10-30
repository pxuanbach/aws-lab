locals {
  function_name = "lambda_to_dynamodb"
}

resource "aws_iam_role" "lambda_function_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_function_policy" {
  name = "lambda_function_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
        ]
        Resource = var.sqs_queue.arn
        Effect = "Allow"
      },
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:BatchWriteItem",
        ]
        Resource = var.dynamodb_table.arn
        Effect = "Allow"
      },
      {
        Action = "logs:CreateLogGroup"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
        Effect = "Allow"
      },
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_function_policy_attachment" {
  role = aws_iam_role.lambda_function_role.name
  policy_arn = aws_iam_policy.lambda_function_policy.arn
}

data "archive_file" "lambda_to_dynamodb_file" {
  type        = "zip"
  source_file = "${path.module}/${local.function_name}.py"
  output_path = "${path.module}/${local.function_name}.py.zip"
}

resource "aws_lambda_function" "lambda_to_dynamodb" {
  function_name = local.function_name
  handler = "lambda_to_dynamodb.handler"
  role = aws_iam_role.lambda_function_role.arn
  runtime = "python3.9"

  filename = data.archive_file.lambda_to_dynamodb_file.output_path
  source_code_hash = data.archive_file.lambda_to_dynamodb_file.output_base64sha256

  timeout = 30
  memory_size = 128

  depends_on = [
    aws_iam_role_policy_attachment.lambda_function_policy_attachment
  ]
}

resource "aws_lambda_event_source_mapping" "sqs_event_lambda_source_mapping" {
  event_source_arn = var.sqs_queue.arn
  function_name = aws_lambda_function.lambda_to_dynamodb.arn
  batch_size = 25
  maximum_batching_window_in_seconds = 5
}
