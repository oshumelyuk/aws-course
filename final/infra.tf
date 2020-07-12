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

resource "aws_subnet" "acPublicSubnet" {
  vpc_id                  = aws_vpc.acVPC.id
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "acPublicSubnet"
  }
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
  subnet_id      = aws_subnet.acPublicSubnet.id
  route_table_id = aws_route_table.acRT.id
}

resource "aws_security_group" "acPublicSG" {
  name   = "acPublicSG"
  vpc_id = aws_vpc.acVPC.id
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

resource "aws_elb" "acELB" {
  name               = "acELB"
  availability_zones = ["us-east-1b"]

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "acELB"
  }
}

#-------------------------
# public EC2 template
#-------------------------

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
      "sqs:*"
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "sns:*"
    ]

    resources = [
      "*",
    ]
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

resource "aws_launch_template" "acPublicEC2Template" {
  name                   = "acPublicEC2Template"
  image_id               = "ami-0323c3dd2da7fb37d"
  instance_type          = "t2.micro"
  user_data              = filebase64("ec2_public.sh")
  key_name               = aws_key_pair.acAccessKey.key_name
  vpc_security_group_ids = [aws_security_group.acPublicSG.id]
  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_accessprofile.arn
  }
}

resource "aws_autoscaling_group" "acAutoScalingGroup" {
  name                = "acAutoScalingGroup"
  vpc_zone_identifier = [aws_subnet.acPublicSubnet.id]
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  #  load_balancers      = [aws_elb.acELB.name]
  launch_template {
    id      = aws_launch_template.acPublicEC2Template.id
    version = "$Latest"
  }
}

# ---------------------------- #

# ---------------------------- #
# NAT instance
# ---------------------------- #

resource "aws_instance" "acNatInstance" {
  ami                    = "ami-00a9d4a05375b2763"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.acAccessKey.key_name
  vpc_security_group_ids = [aws_security_group.acPublicSG.id]
  subnet_id              = aws_subnet.acPublicSubnet.id
  source_dest_check      = false
  tags = {
    Name = "acNATInstance"
  }
}

resource "aws_route_table" "acRTNAT" {
  vpc_id = aws_vpc.acVPC.id
  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.acNatInstance.id
  }

  tags = {
    Name = "acRTNAT"
  }
}

resource "aws_route_table_association" "acRTNatPrivateAssociation" {
  subnet_id      = aws_subnet.acPrivateSubnet.id
  route_table_id = aws_route_table.acRTNAT.id
}

# ---------------------------- #

# ---------------------------- #
# private EC2 instance
# ---------------------------- #

data "aws_iam_policy_document" "private_ec2_accessrole_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "private_ec2_accesspolicy_document" {
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
      "rds:CreateDBInstance",
      "rds:ModifyDBInstance"
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "sqs:*"
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "sns:*"
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "ec2:DescribeTags"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "private_ec2_accessrole" {
  name               = "private_ec2_accessrole"
  assume_role_policy = data.aws_iam_policy_document.private_ec2_accessrole_document.json
}

resource "aws_iam_policy" "private_ec2_accesspolicy" {
  name   = "private_ec2_accesspolicy"
  policy = data.aws_iam_policy_document.private_ec2_accesspolicy_document.json
}

resource "aws_iam_role_policy_attachment" "private_ec2_policy_attach" {
  role       = aws_iam_role.private_ec2_accessrole.name
  policy_arn = aws_iam_policy.private_ec2_accesspolicy.arn
}

resource "aws_iam_instance_profile" "private_ec2_accessprofile" {
  name = "private_ec2_accessprofile"
  role = aws_iam_role.private_ec2_accessrole.name
}

resource "aws_subnet" "acPrivateSubnet" {
  vpc_id            = aws_vpc.acVPC.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "acPrivateSubnet"
  }
}

resource "aws_security_group" "acPrivateSG" {
  name   = "acPrivateSG"
  vpc_id = aws_vpc.acVPC.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.acPublicSubnet.cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.acPublicSubnet.cidr_block]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [aws_subnet.acPublicSubnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "acPrivateInstance" {
  ami                    = "ami-0323c3dd2da7fb37d"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.acAccessKey.key_name
  vpc_security_group_ids = [aws_security_group.acPrivateSG.id]
  subnet_id              = aws_subnet.acPrivateSubnet.id
  user_data              = filebase64("ec2_private.sh")
  iam_instance_profile   = aws_iam_instance_profile.private_ec2_accessprofile.name
  tags = {
    Name    = "acPrivateInstance"
    RDSHost = aws_db_instance.ac_rds.address
  }
}

# ---------------------------- #

# ---------------------------- #
# dynamo DB
# ---------------------------- #

resource "aws_dynamodb_table" "ac-dynamodb-table" {
  name           = "edu-lohika-training-aws-dynamodb"
  billing_mode   = "PROVISIONED"
  write_capacity = 20
  read_capacity  = 20
  hash_key       = "UserName"

  attribute {
    name = "UserName"
    type = "S"
  }
}

# ---------------------------- #

# ---------------------------- #
# RDS 
# ---------------------------- #

resource "aws_security_group" "rds_sg" {
  name = "rds_sg"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "ac_rds" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "11.6"
  port                   = 5432
  identifier             = "edulohikatrainingawsrds"
  name                   = "EduLohikaTrainingAwsRds"
  instance_class         = "db.t2.micro"
  password               = "rootuser"
  username               = "rootuser"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

# ---------------------------- #

# ---------------------------- #
# SNS / SQS
# ---------------------------- #

resource "aws_sqs_queue" "ac_queue_deadletter" {
  name                      = "ac-queue-deadletter"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

resource "aws_sqs_queue" "ac_sqs" {
  name                      = "edu-lohika-training-aws-sqs-topic"
  delay_seconds             = 1
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.ac_queue_deadletter.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sns_topic" "ac_sns_topic" {
  name = "edu-lohika-training-aws-sns-topic"
}

resource "aws_sns_topic_subscription" "ac_sns_subscr" {
  topic_arn = aws_sns_topic.ac_sns_topic.arn
  protocol  = "sms"
  endpoint  = "+380969998877"
}

# ---------------------------- #