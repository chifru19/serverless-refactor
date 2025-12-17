resource "aws_dynamodb_table" "db" {
  name         = "refactor-db"
  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }
}
