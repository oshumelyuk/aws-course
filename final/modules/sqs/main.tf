resource "aws_sqs_queue" "ac_queue_deadletter" {
  name                      = "ac-queue-deadletter"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

resource "aws_sqs_queue" "ac_sqs" {
  name                      = "edu-lohika-training-aws-sqs-queue"
  delay_seconds             = 1
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.ac_queue_deadletter.arn
    maxReceiveCount     = 4
  })
}
