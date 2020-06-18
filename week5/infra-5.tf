provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

output "data" {
  value = [aws_sqs_queue.week5_sqs.id, aws_sns_topic.week5_sns_topic.arn]
}

resource "aws_sqs_queue" "week5_queue_deadletter" {
  name                      = "week5-queue-deadletter"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

resource "aws_sqs_queue" "week5_sqs" {
  name                      = "week5_sqs"
  delay_seconds             = 1
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.week5_queue_deadletter.arn
    maxReceiveCount     = 4
  })

  # fifo_queue                  = true
  # content_based_deduplication = true
}

resource "aws_sns_topic" "week5_sns_topic" {
  name = "week5-sns-topic"
}

resource "aws_sns_topic_subscription" "week5_sns_subscr" {
  topic_arn = aws_sns_topic.week5_sns_topic.arn
  protocol  = "sms"
  endpoint  = "+380969827528"
}