provider "aws" {
    region     = "eu-central-1"
    access_key = var.credentials.access_key
    secret_key = var.credentials.secret_key
  }

resource "aws_vpc" "project_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Project VPC"
  }
}

resource "aws_subnet" "proj-subnet-public-1" {
    vpc_id                  = aws_vpc.project_vpc.id
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone       = "eu-central-1a"

    tags = {
        Name = "Public Subnet"
    }

}


resource "aws_subnet" "private_subnet" {
    vpc_id            = aws_vpc.project_vpc.id
    cidr_block        = "10.0.2.0/24"
    availability_zone = "eu-central-1a"

    tags = {
        Name = "Private Subnet"
    }
  
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.project_vpc.id

tags = {
    Name = "Project IGW"
}

}

resource "aws_network_interface" "ani" {
  subnet_id   = aws_subnet.private_subnet.id
  private_ips = ["10.0.2.100"]

  tags = {
        Name = "Project ANI"
    }
}

resource "aws_route_table" "project_route_table" {
  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  #route {
  #  ipv6_cidr_block        = "::/0"
    
  #}
  tags = {
        Name = "Project Route Table"
    }
}

resource "aws_route_table_association" "public_route" {
  subnet_id      = aws_subnet.proj-subnet-public-1.id
  route_table_id = aws_route_table.project_route_table.id
}

resource "aws_security_group" "react_sg" {
  name        = "allow_react"
  description = "Allow react web server inbound traffic"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    description      = "web server"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
        Name = "React EC2 SG"
    }
}
resource "aws_instance" "ec2_web_instance" {
  ami           = "ami-06c39ed6b42908a36"
  instance_type = "t2.micro"
  key_name      = "MyKeyPair1"

  subnet_id                   = aws_subnet.proj-subnet-public-1.id
  vpc_security_group_ids      = [aws_security_group.react_sg.id]
  associate_public_ip_address = true

  user_data = "${file("react.sh")}"

  tags = {
        Name = "React EC2 Instance"
    }
}