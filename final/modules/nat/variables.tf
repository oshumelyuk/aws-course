variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "ec2_access_key_name" {
  description = "Key to access ec2 instance via ssh"
  type = string
}

variable "nat_subnet_id" {
  description = "Public subnet id"
  type = string
}

variable "private_subnet_id" {
  description = "Private subnet id"
  type = string
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR"
  type = string
}