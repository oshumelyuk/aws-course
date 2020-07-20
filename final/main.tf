provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_key_pair" "acAccessKey" {
  key_name   = "acAccessKey"
  public_key = file("~/.ssh/terraform.pub")
}

resource "aws_vpc" "acVPC" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "acVPC"
  }
}

module "public_ec2" {
  source                   = "./modules/public-ec2"
  vpc_id                   = aws_vpc.acVPC.id
  subnet_cidr              = "10.1.2.0/24"
  subnet_availability_zone = "us-east-1b"
  ec2_access_key_name      = aws_key_pair.acAccessKey.key_name
  desired_ag_capacity      = 1
  max_ag_capacity          = 1
  min_ag_capacity          = 1
  dynamodb_arn             = module.dynamodb.dynamodb_arn
  sns_arn                  = module.sns.sns_arn
  sqs_arn                  = module.sqs.sqs_arn
}

module "private_ec2" {
  source                   = "./modules/private-ec2"
  vpc_id                   = aws_vpc.acVPC.id
  subnet_cidr              = "10.1.1.0/24"
  nat_subnet_cidr          = "10.1.2.0/24"
  subnet_availability_zone = "us-east-1a"
  ec2_access_key_name      = aws_key_pair.acAccessKey.key_name
  rds_host                 = module.rds.rds_host
  rds_arn                  = module.rds.rds_arn
  sns_arn                  = module.sns.sns_arn
  sqs_arn                  = module.sqs.sqs_arn
}

module "nat" {
  source              = "./modules/nat"
  vpc_id              = aws_vpc.acVPC.id
  ec2_access_key_name = aws_key_pair.acAccessKey.key_name
  nat_subnet_id       = module.public_ec2.subnet_id
  private_subnet_id   = module.private_ec2.subnet_id
  private_subnet_cidr = "10.1.1.0/24"
}

module "rds" {
  source                   = "./modules/rds"
  vpc_id                   = aws_vpc.acVPC.id
  subnet_1_cidr              = "10.1.3.0/24"
  subnet_1_availability_zone = "us-east-1a"
  subnet_2_cidr              = "10.1.4.0/24"
  subnet_2_availability_zone = "us-east-1b"
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "sqs" {
  source = "./modules/sqs"
}

module "sns" {
  source = "./modules/sns"
  phone  = "+380969827528"
}

resource "aws_internet_gateway" "acIG" {
  vpc_id = aws_vpc.acVPC.id
  tags = {
    Name = "acIG"
  }
}

resource "aws_route_table" "acRT" {
  vpc_id = aws_vpc.acVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.acIG.id
  }

  tags = {
    Name = "acRT"
  }
}

resource "aws_route_table_association" "acRTAssociation" {
  subnet_id      = module.public_ec2.subnet_id
  route_table_id = aws_route_table.acRT.id
}