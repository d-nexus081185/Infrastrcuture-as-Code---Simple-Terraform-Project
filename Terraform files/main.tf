# VPC Resource
resource "aws_vpc" "demo-vpc" {
  cidr_block = "12.0.0.0/16"

  tags = {
    Name = "demo-vpc"
  }
}

# Internet Gateway Resource
resource "aws_internet_gateway" "demo-gw" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "demo-gw"
  }
}

# Subnet Resource
resource "aws_subnet" "demo-public-subnet" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "12.0.2.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "demo-public-subnet"
  }
}

# Route Table Resource
resource "aws_route_table" "demo-RT" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-gw.id
  }

  tags = {
    Name = "demo-RT"
  }
}

# Associate Subnet to Route Table
resource "aws_route_table_association" "Association-demo-public-subnet" {
  subnet_id      = aws_subnet.demo-public-subnet.id
  route_table_id = aws_route_table.demo-RT.id
}

# Security Group Resource
resource "aws_security_group" "demo-SG" {
  vpc_id = aws_vpc.demo-vpc.id

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

  tags = {
    Name = "demo-SG"
  }
}

# EC2 Instance
resource "aws_instance" "web-server" {
  ami                    = "ami-04b70fa74e45c3917"  # Change to a valid AMI ID for your region
  instance_type          = "t3.micro"
  #key_name               = "access-key"  # Ensure this key pair exists in your AWS account
  subnet_id              = aws_subnet.demo-public-subnet.id
  vpc_security_group_ids = [aws_security_group.demo-SG.id]

  tags = {
    Name = "web-server"
  }
}

output "web-server" {
  value = aws_instance.web-server.public_ip
}
