resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size        = 10
  event_source_arn  = "${aws_sqs_queue.activity_queue.arn}"
  enabled           = true
  function_name     = "${aws_lambda_function.lambda_to_dynamodb.arn}"
}