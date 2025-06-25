provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0745beb9f7f34ef64" 
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.allow_http.id]
  key_name               = "tp1" 

  tags = {
    Name = "nginx-packer-server"
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Autorise le trafic HTTP"

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
