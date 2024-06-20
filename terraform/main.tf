provider "aws" {
  region = "us-west-2"
}
terraform {
  backend "s3" {
    bucket         = "terrafrom-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"  # Optional, for state locking
  }
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "4.35.0"
    }
  }
}
resource "aws_security_group" "default_sg" {
  name        = "default-sg"
  description = "default security group allowing ssh and http/https"
  vpc_id      = "vpc-00ab9fc9fff99d8f4"

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH traffic from my home ip"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["70.66.174.244/32"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "default-sg"
  }
}

resource "aws_instance" "qliu" {
  ami                    = "ami-0b20a6f09484773af"
  instance_type          = "t2.micro"
  key_name               = "default"
  associate_public_ip_address = true
  subnet_id              = "subnet-08e81699a5b0c4d99"
  security_groups        = [aws_security_group.default_sg.name]

  tags = {
    Name = "qliu"
  }
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.qliu.public_ip
}


# Configure the Cloudflare provider
provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

# Define the DNS record
resource "cloudflare_record" "qliu_ca" {
  zone_id = var.cloudflare_zone_id
  name    = var.dns_name
  value   = aws_instance.qliu.public_ip
  type    = "A"
  ttl     = 300
}
