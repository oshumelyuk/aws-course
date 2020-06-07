provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "aws_iam_policy_document" "accesss3role_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "accesss3policy_document" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*"
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

resource "aws_iam_role" "accesss3role" {
  name               = "accesss3role"
  assume_role_policy = data.aws_iam_policy_document.accesss3role_document.json
}

resource "aws_iam_policy" "accesss3policy" {
  name   = "accesss3policy"
  policy = data.aws_iam_policy_document.accesss3policy_document.json
}

resource "aws_iam_role_policy_attachment" "s3_policy_attach" {
  role       = aws_iam_role.accesss3role.name
  policy_arn = aws_iam_policy.accesss3policy.arn
}

resource "aws_iam_instance_profile" "accesss3profile" {
  name = "accesss3profile"
  role = aws_iam_role.accesss3role.name
}

resource "aws_instance" "myec2instance" {
  ami                  = "ami-0323c3dd2da7fb37d"
  instance_type        = "t2.micro"
  key_name             = aws_key_pair.accessKeyTerra.key_name
  security_groups      = [aws_security_group.defaultSecurityGroup.name]
  iam_instance_profile = aws_iam_instance_profile.accesss3profile.name
  user_data            = filebase64("my-script-3.sh")
  #connection {
  #  type        = "ssh"
  #  user        = "ec2-user"
  #  private_key = file("~/.ssh/terraform")
  #  host        = self.public_ip
  #}

  #provisioner "remote-exec" {
  #  inline = [
  #    "aws s3 cp s3://ac-buk/aws-s3.txt aws-dwnl.txt"
  #  ]
  #}
}