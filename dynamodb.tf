resource "aws_dynamodb_table" "data_table" {
  name             = var.dynamodb_table_name
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "PK" # Partition Key
  range_key        = "SK" # Sort Key
  
  attribute {
    name = "PK"
    type = "S"
  }
  
  attribute {
    name = "SK"
    type = "S"
  }

  tags = {
    Name = var.dynamodb_table_name
  }
}
