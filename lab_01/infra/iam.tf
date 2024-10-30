resource "aws_iam_role" "lambda_function_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_function_role_policy_attachment" {
  policy_arn = "${aws_iam_policy.lambda_function_policy.arn}"
  role = "${aws_iam_role.lambda_function_role.name}"
}

resource "aws_iam_policy" "lambda_function_policy" {
  policy = "${data.aws_iam_policy_document.lambda_function_data.json}"
}

data "aws_iam_policy_document" "lambda_function_data" {
  statement {
    sid       = "AllowSQSPermissions"
    effect    = "Allow"
    resources = ["arn:aws:sqs:*"]

    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
    ]
  }

  statement {
    sid       = "AllowInvokingLambdas"
    effect    = "Allow"
    resources = ["arn:aws:lambda:ap-southeast-1:*:function:*"]
    actions   = ["lambda:InvokeFunction"]
  }

  statement {
    sid       = "AllowCreatingLogGroups"
    effect    = "Allow"
    resources = ["arn:aws:logs:ap-southeast-1:*:*"]
    actions   = ["logs:CreateLogGroup"]
  }
  statement {
    sid       = "AllowWritingLogs"
    effect    = "Allow"
    resources = ["arn:aws:logs:ap-southeast-1:*:log-group:/aws/lambda/*:*"]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}