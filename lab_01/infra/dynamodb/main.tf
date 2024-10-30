resource "aws_dynamodb_table" "test_table" {
  name = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  table_class = "STANDARD"
  hash_key = "messageId"
  range_key = "createdAt"

  attribute {
    name = "messageId"
    type = "S"
  }

  attribute {
    name = "createdAt"
    type = "N"
  }
}
