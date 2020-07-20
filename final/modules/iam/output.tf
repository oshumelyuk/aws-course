output "ac_s3_accesspolicy_arn" {
  description = "S3 access policy ARN"
  value       = aws_iam_policy.ac_s3_accesspolicy.arn
}

output "ac_dynamodb_accesspolicy_arn" {
  description = "DynamoDB access policy ARN"
  value       = aws_iam_policy.ac_dynamodb_accesspolicy.arn
}

output "ac_sqs_accesspolicy_arn" {
  description = "SQS access policy ARN"
  value       = aws_iam_policy.ac_sqs_accesspolicy.arn
}

output "ac_sns_accesspolicy_arn" {
  description = "SNS access policy ARN"
  value       = aws_iam_policy.ac_sns_accesspolicy.arn
}

output "ac_rds_accesspolicy_arn" {
  description = "RDS access policy ARN"
  value       = aws_iam_policy.ac_rds_accesspolicy.arn
}

output "ac_ec2tags_accesspolicy_arn" {
  description = "EC2 tags access policy ARN"
  value       = aws_iam_policy.ac_ec2tags_accesspolicy.arn
}