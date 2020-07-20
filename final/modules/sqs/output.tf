
output "sqs_arn" {
  description = "SQS ARN"
  value       = aws_sqs_queue.ac_sqs.arn
}