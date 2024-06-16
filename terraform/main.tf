provider "aws" {
  region = "us-east-1"  # You can change the region as per your preference
}

resource "aws_instance" "qliu.ca" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"               # Instance type, you can change this too
  
  tags = {
    Name = "qliu.ca"
  }
}

