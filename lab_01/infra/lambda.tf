data "archive_file" "lambda_to_dynamodb" {
  type        = "zip"
  source_file = "${path.module}/lambda_to_dynamodb.py"
  output_path = "${path.module}/lambda_to_dynamodb.py.zip"
}

resource "aws_lambda_function" "lambda_to_dynamodb" {
  function_name = "lambda_function"
  handler = "lambda_function.handler"
  role = "${aws_iam_role.lambda_function_role.arn}"
  runtime = "python3.12"

  filename = "${data.archive_file.lambda_to_dynamodb.output_path}"
  source_code_hash = "${data.archive_file.lambda_to_dynamodb.output_base64sha256}"

  timeout = 30
  memory_size = 128
}