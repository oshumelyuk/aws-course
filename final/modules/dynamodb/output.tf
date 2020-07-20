output "dynamodb_arn" {
  description = "DynamoDB ARN"
  value       = aws_dynamodb_table.ac-dynamodb-table.arn
}