resource "aws_ecr_repository" "test_ecr" {
  name                 = "flask-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


output "ecr_url" {
  value = aws_ecr_repository.test_ecr.repository_url
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "ec2_sg" {
  name = "terraform-ec2-sg"

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# aws keypair
resource "aws_key_pair" "key_pair" {
  depends_on = [tls_private_key.private_key]
  key_name   = "ec2-flask-app"
  public_key = tls_private_key.private_key.public_key_openssh
}

# save privateKey
resource "local_file" "saveKey" {
  depends_on = [aws_key_pair.key_pair]
  content    = tls_private_key.private_key.private_key_pem
  filename   = "ec2-flask-app.pem"
}


resource "aws_instance" "single_webserver" {
  ami           = "ami-07ebfd5b3428b6f4d"
  instance_type = "t2.micro"
  key_name               = "ec2-flask-app"

  user_data = <<-EOF
                #!/bin/bash
                curl -fsSL https://get.docker.com -o get-docker.sh
                sudo sh get-docker.sh
                sudo usermod -aG docker ubuntu
                sudo apt install awscli
                EOF

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  tags = {
    Name = "terraform-ec2-example"
  }
}

output "public_ip" {
  value       = aws_instance.single_webserver.*.public_ip
}
