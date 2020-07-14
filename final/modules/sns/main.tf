
resource "aws_sns_topic" "ac_sns_topic" {
  name = "edu-lohika-training-aws-sns-topic"
}

resource "aws_sns_topic_subscription" "ac_sns_subscr" {
  topic_arn = aws_sns_topic.ac_sns_topic.arn
  protocol  = "sms"
  endpoint  = var.phone
}