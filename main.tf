provider "aws" {
  region = "ap-south-1"
  profile = "default"
} 
  
resource "aws_lb" "lb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = var.load_balancer_type
}
 
resource "aws_instance" "webTier" {
  ami = var.ami
  instance_type = var.instance_type
  count = length(var.webservers)
  
  tags = {
      Name = var.webservers[count.index]
}
}

resource "aws_db_instance" "p_mydb" {
  allocated_storage = 10
  engine = var.engine
  engine_version = "14.2.R1"
  instance_class = var.instance_class
  db_name = "mydb"
  username = var.username
  password = var.password
}
 




# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Subnets
# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  
}

# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  vpc        = true
}

# NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name        = "nat"
    Environment = "${var.environment}"
  }
}

# Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  
}


# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false

  
}


# Routing tables to route traffic for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  
}

# Routing tables to route traffic for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  
}

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# Route for NAT
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Route table associations for both Public & Private Subnets
resource "aws_route_table_association" "public" {
  
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {

  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private.id
}

# Default Security Group of VPC
resource "aws_security_group" "lbsg" {
  name        = "${var.environment}-default-sg"
  description = "This secruity group is for Application Load Balancer"
  vpc_id      = aws_vpc.vpc.id
  depends_on = [
    aws_vpc.vpc
  ]

    ingress {
    from_port = "22"
    to_port   = "22"
    protocol  = "ssh"
    self      = true
  }
     ingress {
    from_port = "8080"
    to_port   = "8080"
    protocol  = "webserver"
    self      = true
  }

  
  tags = {
    Environment = "${var.environment}"
  }
}
resource "aws_security_group" "dbsg" {
  name        = "${var.environment}-default-sg"
  description = "Default SG to alllow traffic from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on = [
    aws_vpc.vpc
  ]

    ingress {
    from_port = "22"
    to_port   = "22"
    protocol  = "ssh"
    self      = true
  }
     ingress {
    from_port = "5432"
    to_port   = "5432"
    protocol  = "postgresql"
    self      = true
  }

  
  tags = {
    Environment = "${var.environment}"
  }
}