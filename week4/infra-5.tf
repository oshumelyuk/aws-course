provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_key_pair" "accessKey4" {
  key_name   = "accessKey4"
  public_key = file("~/.ssh/terraform.pub")
}

resource "aws_vpc" "week4VPC" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "week4VPC"
  }
}

resource "aws_subnet" "week4PrivateSubnet" {
  vpc_id            = aws_vpc.week4VPC.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "week4PrivateSubnet"
  }
}

resource "aws_subnet" "week4PublicSubnet" {
  vpc_id                  = aws_vpc.week4VPC.id
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "week4PublicSubnet"
  }
}

resource "aws_internet_gateway" "week4IG" {
  vpc_id = aws_vpc.week4VPC.id
  tags = {
    Name = "week4IG"
  }
}

resource "aws_route_table" "week4RT" {
  vpc_id = aws_vpc.week4VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.week4IG.id
  }

  tags = {
    Name = "week4RT"
  }
}

resource "aws_route_table" "week4RTNAT" {
  vpc_id = aws_vpc.week4VPC.id
  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.week4NatInstance.id
  }

  tags = {
    Name = "week4RTNAT"
  }
}

resource "aws_route_table_association" "week4RTAssociation" {
  subnet_id      = aws_subnet.week4PublicSubnet.id
  route_table_id = aws_route_table.week4RT.id
}

resource "aws_route_table_association" "week4RTNatAssociation" {
  subnet_id      = aws_subnet.week4PrivateSubnet.id
  route_table_id = aws_route_table.week4RTNAT.id
}

resource "aws_security_group" "week4PublicSG" {
  name   = "week4PublicSG"
  vpc_id = aws_vpc.week4VPC.id
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

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_subnet.week4PrivateSubnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "week4PrivateSG" {
  name   = "week4PrivateSG"
  vpc_id = aws_vpc.week4VPC.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.week4PublicSubnet.cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.week4PublicSubnet.cidr_block]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [aws_subnet.week4PublicSubnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "week4PublicInstance" {
  ami                    = "ami-0323c3dd2da7fb37d"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.accessKey4.key_name
  vpc_security_group_ids = [aws_security_group.week4PublicSG.id]
  subnet_id              = aws_subnet.week4PublicSubnet.id
  user_data              = filebase64("my-script-public.sh")
  tags = {
    Name = "week4PublicInstance"
  }
}

resource "aws_instance" "week4PrivateInstance" {
  ami                    = "ami-0323c3dd2da7fb37d"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.accessKey4.key_name
  vpc_security_group_ids = [aws_security_group.week4PrivateSG.id]
  subnet_id              = aws_subnet.week4PrivateSubnet.id
  user_data              = filebase64("my-script-private.sh")
  tags = {
    Name = "week4PrivateInstance"
  }
}

resource "aws_instance" "week4NatInstance" {
  ami                    = "ami-00a9d4a05375b2763"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.accessKey4.key_name
  vpc_security_group_ids = [aws_security_group.week4PublicSG.id]
  subnet_id              = aws_subnet.week4PublicSubnet.id
  source_dest_check      = false
  tags = {
    Name = "week4NATInstance"
  }
}

resource "aws_lb_target_group" "week4TG" {
  name     = "week4TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.week4VPC.id
  health_check {
    path     = "/index.html"
    protocol = "HTTP"
  }
}

resource "aws_lb_target_group_attachment" "week4TGPublicInstanceAttachment" {
  target_group_arn = aws_lb_target_group.week4TG.arn
  target_id        = aws_instance.week4PublicInstance.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "week4TGPrivateInstanceAttachment" {
  target_group_arn = aws_lb_target_group.week4TG.arn
  target_id        = aws_instance.week4PrivateInstance.id
  port             = 80
}

resource "aws_lb" "week4LB" {
  name               = "week4LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.week4PublicSG.id]
  subnets            = [aws_subnet.week4PublicSubnet.id, aws_subnet.week4PrivateSubnet.id]

  tags = {
    Name = "week4LB"
  }
}

resource "aws_lb_listener" "week4LBListener" {
  load_balancer_arn = aws_lb.week4LB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.week4TG.arn
  }
}