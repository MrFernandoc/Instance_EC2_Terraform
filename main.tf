provider "aws" {
  region = var.aws_region
}

data "aws_ami" "cloud9_ubuntu22" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*Cloud9Ubuntu22*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_security_group" "web_sg" {
  name        = "web-sec-group"
  description = "Permite SSH y HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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

resource "aws_instance" "vm" {
  ami                         = data.aws_ami.cloud9_ubuntu22.id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.web_sg.id]

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp2"
  }

  tags = {
    Name = var.instance_name
  }
}
