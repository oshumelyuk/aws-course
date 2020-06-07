provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_key_pair" "accessKeyTerra" {
  key_name   = "accessKeyTerra"
  public_key = file("~/.ssh/terraform.pub")
}

# Security group to access the instance over SSH and HTTP
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

resource "aws_launch_template" "testtemplate" {
  name          = "testtemplate"
  image_id      = "ami-0323c3dd2da7fb37d"
  instance_type = "t2.micro"
  user_data       = filebase64("my-script.sh")
  #user_data            = "IyEvYmluL2Jhc2gKc3VkbyBhbWF6b24tbGludXgtZXh0cmFzIGluc3RhbGwgamF2YS1vcGVuamRrMTEgLS1hc3N1bWUteWVz"
  key_name             = aws_key_pair.accessKeyTerra.key_name
  security_group_names = [aws_security_group.defaultSecurityGroup.name]
}

resource "aws_autoscaling_group" "terratest" {
  name               = "terraform-test"
  availability_zones = ["us-east-1a"]
  desired_capacity   = 2
  max_size           = 2
  min_size           = 2

  launch_template {
    id      = aws_launch_template.testtemplate.id
    version = "$Latest"
  }
}