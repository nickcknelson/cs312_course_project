terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
}

resource "aws_security_group" "minecraft" {
  name        = "minecraft-sg"
  description = "Allow Minecraft port"

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "app_server" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.minecraft.id]
  associate_public_ip_address = true

  key_name = aws_key_pair.course_key.key_name

  tags = {
    Name = "minecraft-server"
  }
}
resource "aws_key_pair" "course_key" {
  key_name   = "mc-final"
  public_key = file("/home/nnelson/.ssh/mc-final.pub")
}


output "public_ip" {
  description = "Public IP of the Minecraft server"
  value       = aws_instance.app_server.public_ip
}
