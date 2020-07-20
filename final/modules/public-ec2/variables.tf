variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "subnet_cidr" {
  description = "CIDR subnet"
  type = string
}

variable "subnet_availability_zone" {
  description = "Availabilty zone"
  type = string
}

variable "ec2_access_key_name" {
  description = "Key to access ec2 instance via ssh"
  type = string
}

variable "desired_ag_capacity" {
  description = "Desired autoscaling group capacity"
  type = number
}

variable "max_ag_capacity" {
  description = "Max autoscaling group capacity"
  type = number
}

variable "min_ag_capacity" {
  description = "Min autoscaling group capacity"
  type = number
}

variable "dynamodb_arn" {
  description = "DynamoDB arn"
  type = string
}

variable "sqs_arn" {
  description = "SQS arn"
  type = string
}

variable "sns_arn" {
  description = "SNS arn"
  type = string
}