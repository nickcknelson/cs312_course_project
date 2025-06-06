resource "aws_key_pair" "deployer" {
  key_name   = var.key-name
  public_key = file("${path.module}/my-minecraft-key.pub")
}

resource "aws_security_group" "network-security-group" {
  name        = var.network-security-group-name
  description = "Allow Minecraft and SSH ports"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 25565
    to_port     = 25565
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

resource "aws_instance" "ubuntu-vm-instance" {
  ami                    = var.ubuntu-ami
  instance_type          = var.ubuntu-instance-type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.network-security-group.id]

  tags = {
    Name = "minecraft-server"
  }
}

output "minecraft_server_ip" {
  description = "Public IP of the Minecraft server"
  value       = aws_instance.ubuntu-vm-instance.public_ip
}