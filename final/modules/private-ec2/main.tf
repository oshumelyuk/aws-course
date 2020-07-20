
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
      "arn:aws:s3:::ac-buk/*",
    ]
  }

  statement {
    actions = [
      "rds:CreateDBInstance",
      "rds:ModifyDBInstance"
    ]

    resources = [
      var.rds_arn,
    ]
  }

  statement {
    actions = [
      "sqs:*"
    ]

    resources = [
      var.sqs_arn,
    ]
  }

  statement {
    actions = [
      "sns:*"
    ]

    resources = [
      var.sns_arn,
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
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr
  availability_zone = var.subnet_availability_zone
  tags = {
    Name = "acPrivateSubnet"
  }
}

resource "aws_security_group" "acPrivateSG" {
  name   = "acPrivateSG"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.nat_subnet_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.nat_subnet_cidr]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [var.nat_subnet_cidr]
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
  key_name               = var.ec2_access_key_name
  vpc_security_group_ids = [aws_security_group.acPrivateSG.id]
  subnet_id              = aws_subnet.acPrivateSubnet.id
  user_data              = filebase64("ec2_private.sh")
  iam_instance_profile   = aws_iam_instance_profile.private_ec2_accessprofile.name
  tags = {
    Name = "acPrivateInstance"
    RDSHost = var.rds_host
  }
}

