resource "aws_dynamodb_table" "ddb_table_activity" {
  name             = "Activity"
  hash_key         = "MessageId"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "MessageId"
    type = "S"
  }

}