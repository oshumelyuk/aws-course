
resource "aws_dynamodb_table" "ac-dynamodb-table" {
  name           = "edu-lohika-training-aws-dynamodb"
  billing_mode   = "PROVISIONED"
  write_capacity = 20
  read_capacity  = 20
  hash_key       = "UserName"

  attribute {
    name = "UserName"
    type = "S"
  }
}