resource "aws_security_group" "rds_sg" {
  name = "rds_sg"
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