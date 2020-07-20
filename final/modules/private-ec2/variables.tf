variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "subnet_cidr" {
  description = "CIDR of private subnet"
  type = string
}

variable "nat_subnet_cidr" {
  description = "CIDR of subnet where NAT instance is located"
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

variable "rds_host" {
  description = "RDS host"
  type = string
}

variable "rds_arn" {
  description = "RDS arn"
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

