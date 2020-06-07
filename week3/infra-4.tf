provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

output "rds_data" {
  value = [aws_db_instance.awscourse-rds.port, aws_db_instance.awscourse-rds.address]
}

variable "awscourse_rds_password" {
  type = string
}

data "aws_iam_policy_document" "ec2_accessrole_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2_accesspolicy_document" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*"
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "dynamodb:ListTables",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:PutItem"
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "rds:CreateDBInstance",
      "rds:ModifyDBInstance"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_key_pair" "accessKeyTerra" {
  key_name   = "accessKeyTerra"
  public_key = file("~/.ssh/terraform.pub")
}

resource "aws_dynamodb_table" "awscourse-dynamodb-table" {
  name           = "AwsCourse"
  billing_mode   = "PROVISIONED"
  write_capacity = 20
  read_capacity  = 20
  hash_key       = "week"
  range_key      = "title"

  attribute {
    name = "week"
    type = "N"
  }

  attribute {
    name = "title"
    type = "S"
  }
}

resource "aws_security_group" "rds_sg" {
  name = "rds_sg"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "awscourse-rds" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "11.6"
  identifier             = "awscourse-rds"
  name                   = "AwsCourseRDS"
  instance_class         = "db.t2.micro"
  password               = var.awscourse_rds_password
  username               = "postgres"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

resource "aws_security_group" "defaultSecurityGroup" {
  name = "defaultSecurityGroup"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_accessrole" {
  name               = "ec2_accessrole"
  assume_role_policy = data.aws_iam_policy_document.ec2_accessrole_document.json
}

resource "aws_iam_policy" "ec2_accesspolicy" {
  name   = "ec2_accesspolicy"
  policy = data.aws_iam_policy_document.ec2_accesspolicy_document.json
}

resource "aws_iam_role_policy_attachment" "s3_policy_attach" {
  role       = aws_iam_role.ec2_accessrole.name
  policy_arn = aws_iam_policy.ec2_accesspolicy.arn
}

resource "aws_iam_instance_profile" "ec2_accessprofile" {
  name = "ec2_accessprofile"
  role = aws_iam_role.ec2_accessrole.name
}

resource "aws_instance" "myec2instance" {
  ami                  = "ami-0323c3dd2da7fb37d"
  instance_type        = "t2.micro"
  key_name             = aws_key_pair.accessKeyTerra.key_name
  security_groups      = [aws_security_group.defaultSecurityGroup.name]
  iam_instance_profile = aws_iam_instance_profile.ec2_accessprofile.name
  user_data            = filebase64("my-script-4.sh")
}