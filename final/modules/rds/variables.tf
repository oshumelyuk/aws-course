variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "subnet_1_cidr" {
  description = "CIDR of RDS subnet"
  type = string
}

variable "subnet_2_cidr" {
  description = "CIDR of RDS subnet"
  type = string
}

variable "subnet_1_availability_zone" {
  description = "Subnet availability zone"
  type = string
}

variable "subnet_2_availability_zone" {
  description = "Subnet availability zone"
  type = string
}