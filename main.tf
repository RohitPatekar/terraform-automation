provider "aws" {
access_key = "AKIARERYWASJHFK7RG7B"
secret_key = "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"
region = "us-east-1"
}

resource "aws_vpc" "rohit-vpc" {
cidr_block = "10.0.0.0/16"
enable_dns_hostnames = true
tags = {
Name = "terraform-aws-vpc"
}
}

resource "aws_internet_gateway" "rohit-igw" {
  vpc_id = aws_vpc.rohit-vpc.id

  tags = {
    Name = "terraform-aws-igw"
  }
}

resource "aws_subnet" "rohit-pub-sub" {
  vpc_id     = aws_vpc.rohit-vpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "terraform-public-subnet"
  }
}


resource "aws_route_table" "rohit-pub-rt" {
  vpc_id = aws_vpc.rohit-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rohit-igw.id
  }

  tags = {
    Name = "terraform-public-route"
  }
}

resource "aws_route_table_association" "rohit-pub-rta" {
  subnet_id = aws_subnet.rohit-pub-sub.id
  route_table_id = aws_route_table.rohit-pub-rt.id
}

resource "aws_key_pair" "rohit-key-pair" {
  key_name   = "rohit-kp"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAgP/4zT+8mAuZqHAcazN1CU1OQjBZu5Zk4jM0oh14FbZI1eJsTlubbjYAHx5cNik9hpPOgHv38g87DfYsVR8SlyL0eLOxbQleC6E5PoPC7aWIC5VCGKjiQDst2k9JRjCJzzncU2dm7DqE9teFYbvxjx7tNkuXd67/EpA1y3UHD2LZUFDqnQvDeCGa0YpDT8kpu8ZXmdn+9YC+CzzywX4zW8T2mXmGRZjA2guAb4zQ2gmJa7ZU9sgh7LxZqWrYwAgOtV82LzHFJ5tWV6G4u//6nhpGpNzVICt7WfPK9HkAaHCYGkfodFNOrKK/TW2LJUyjapy/oKXWfkaIUCEZxGlnQQ== rsa-key-20210427"
}

resource "aws_security_group" "rohit-sg" {
  name        = "APPSG"
  description = "Security Group for EC2"
  vpc_id      = aws_vpc.rohit-vpc.id

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port        = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

 egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "terraform-security-group"
  }
}

resource "aws_instance" "rohit-ec2-instance" {
  ami           = "ami-0742b4e673072066f"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.rohit-sg.id]
  subnet_id = aws_subnet.rohit-pub-sub.id
  key_name = "rohit-kp"
  associate_public_ip_address = true
  tags = {
    Name = "rohit-ec2-instance"
  }
}

output "rohit-public-ip" {
	value = aws_instance.rohit-ec2-instance.public_ip
}
