resource "aws_security_group" "rds_sg" {
  name = "rds_sg"
  vpc_id  = var.vpc_id
  ingress {
    from_port   = 5432
    to_port     = 5432
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

resource "aws_db_subnet_group" "ac_rds_sg" {
  name       = "ac_rds_sg"
  subnet_ids = [aws_subnet.acRDSSubnet1.id, aws_subnet.acRDSSubnet2.id]

  tags = {
    Name = "ac RDS subnet group"
  }
}

resource "aws_subnet" "acRDSSubnet1" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_1_cidr
  availability_zone       = var.subnet_1_availability_zone
  tags = {
    Name = "acRDSSubnet1"
  }
}

resource "aws_subnet" "acRDSSubnet2" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_2_cidr
  availability_zone       = var.subnet_2_availability_zone
  tags = {
    Name = "acRDSSubnet2"
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
  db_subnet_group_name   = aws_db_subnet_group.ac_rds_sg.name
}