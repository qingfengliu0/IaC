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

# Retrieve the default VPC
data "aws_vpc" "default" {
  default = true
}

# Retrieve the default subnet in the specified availability zone
data "aws_subnet" "default" {
  default_for_az = true
  vpc_id         = data.aws_vpc.default.id

  filter {
    name   = "availability-zone"
    values = ["us-west-2a"]  # Replace with your desired AZ
  }
}

# Retrieve the latest Amazon Linux 2 AMI
data "aws_ami" "latest_amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
# Generate an SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key locally
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/id_rsa"
  file_permission = "0600"
}

# Save the public key locally
resource "local_file" "public_key" {
  content  = tls_private_key.ssh_key.public_key_openssh
  filename = "${path.module}/id_rsa.pub"
}

# Upload the public key to AWS
resource "aws_key_pair" "ssh_key" {
  key_name   = "my-ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_security_group" "default_sg" {
  name        = "default-sg"
  description = "default security group allowing ssh and http/https"
  vpc_id      = data.aws_vpc.default.id

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
    cidr_blocks = ["70.66.174.244/32"]  # Replace with your home IP
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
  ami                    = data.aws_ami.latest_amazon_linux_2.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ssh_key.key_name 
  associate_public_ip_address = true
  subnet_id              = data.aws_subnet.default.id
  vpc_security_group_ids = [aws_security_group.default_sg.id]


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

