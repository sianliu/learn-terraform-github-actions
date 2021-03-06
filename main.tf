terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source = "hashicorp/random"
    }
  }

  backend "remote" {
    organization = "wallextech"

    workspaces {
      name = "gh-actions-demo"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"

  assume_role {
    role_arn = "arn:aws:iam::821353914239:role/OrganizationAccountAccessRole"
  }
}

provider "random" {}

resource "random_pet" "sg" {}

resource "aws_instance" "web" {
  ami           = "ami-015a6758451df3cb9"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}