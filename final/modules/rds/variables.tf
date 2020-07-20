variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "subnet_cidr" {
  description = "CIDR of RDS subnet"
  type = string
}

variable "subnet_availability_zone" {
  description = "Subnet availability zone"
  type = string
}