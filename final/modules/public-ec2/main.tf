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

resource "aws_subnet" "acPublicSubnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.subnet_availability_zone
  tags = {
    Name = "acPublicSubnet"
  }
}

resource "aws_security_group" "acPublicSG" {
  name   = "acPublicSG"
  vpc_id = var.vpc_id
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

resource "aws_launch_template" "acPublicEC2Template" {
  name                   = "acPublicEC2Template"
  image_id               = "ami-0323c3dd2da7fb37d"
  instance_type          = "t2.micro"
  user_data              = filebase64("ec2_public.sh")
  key_name               = var.ec2_access_key_name
  vpc_security_group_ids = [aws_security_group.acPublicSG.id]
  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_accessprofile.arn
  }
}

resource "aws_autoscaling_group" "acAutoScalingGroup" {
  name                = "acAutoScalingGroup"
  vpc_zone_identifier = [aws_subnet.acPublicSubnet.id]
  desired_capacity    = var.desired_ag_capacity
  max_size            = var.max_ag_capacity
  min_size            = var.min_ag_capacity
  load_balancers      = [aws_elb.acELB.name]
  launch_template {
    id      = aws_launch_template.acPublicEC2Template.id
    version = "$Latest"
  }
}

resource "aws_elb" "acELB" {
  name            = "acELB"
  security_groups = [aws_security_group.acPublicSG.id]
  subnets         = [aws_subnet.acPublicSubnet.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:80"
    interval            = 30
  }

  tags = {
    Name = "acELB"
  }
}