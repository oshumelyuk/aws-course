resource "aws_security_group" "acNatSG" {
  name   = "acNatSG"
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

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.private_subnet_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "acNatInstance" {
  ami                    = "ami-00a9d4a05375b2763"
  instance_type          = "t2.micro"
  key_name               = var.ec2_access_key_name
  vpc_security_group_ids = [aws_security_group.acNatSG.id]
  subnet_id              = var.nat_subnet_id
  source_dest_check      = false
  tags = {
    Name = "acNATInstance"
  }
}

resource "aws_route_table" "acRTNAT" {
  vpc_id = var.vpc_id
  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.acNatInstance.id
  }

  tags = {
    Name = "acRTNAT"
  }
}

resource "aws_route_table_association" "acRTNatPrivateAssociation" {
  subnet_id      = var.private_subnet_id
  route_table_id = aws_route_table.acRTNAT.id
}