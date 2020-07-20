
output "sns_arn" {
  description = "SNS ARN"
  value       = aws_sns_topic.ac_sns_topic.arn
}