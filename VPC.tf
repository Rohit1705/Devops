#provider information 

provider "aws" {
  access_key = var.access_key 
  secret_key = var.secret_key 
  region = us-east-1
}

#creation of VPC
resource "aws_vpc" "production-vpc" {
  cidr_block            = var.vpc_cidr
  enable_dns_hostnames  = true

  tags {
    Name = "Production-VPC"
  }
}


# creation of public subnet
resource "aws_subnet" "public-subnet-1" {
  cidr_block        = var.subnetCIDRblock1
  vpc_id            = aws_vpc.production-vpc.id
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone = var.availabilityZone1

  tags {
    Name = "Public-Subnet-1"
  }
}

# creation of private subnet
resource "aws_subnet" "private-subnet-1" {
  cidr_block        = var.subnetCIDRblock2
  vpc_id            = aws_vpc.production-vpc.id
  availability_zone = var.availabilityZone2

  tags {
    Name = "Private-Subnet-1"
  }
}

# Create the Security Group
resource "aws_security_group" "My_VPC_Security_Group" {
  vpc_id       = aws_vpc.production-vpc.id
  
  # allow ingress of port 22
  ingress {
    cidr_blocks = var.ingressCIDRblock  
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  } 
  
  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
   Name = "My VPC Security Group"
   
}
}


#create of Network access control list  public subnet
resource "aws_network_acl" "My_public_ACL" {
  vpc_id = aws_vpc.production-vpc.id
  subnet_ids = [ aws_subnet.public-subnet-1.id ]
# allow ingress port 22
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.destinationCIDRblock 
    from_port  = 22
    to_port    = 22
  }
  
  # allow ingress port 80 
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.destinationCIDRblock 
    from_port  = 80
    to_port    = 80
  }
  
  # allow ingress ephemeral ports 
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 1024
    to_port    = 65535
  }
  
  # allow egress port 22 
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 22 
    to_port    = 22
  }
  
  # allow egress port 80 
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 80  
    to_port    = 80 
  }
 
  # allow egress ephemeral ports
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 1024
    to_port    = 65535
  }
tags = {
    Name = "My_public_ACL"
}
} 

# creation of public route table 
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.production-vpc.id

  tags {
    Name = "Public-Route-Table"
  }
}


# creation of private route table
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.production-vpc.id

  tags {
    Name = "Private-Route-Table"
  }
}


# route table association with public subnet
resource "aws_route_table_association" "public-subnet-1-association" {
  route_table_id  = aws_route_table.public-route-table.id
  subnet_id       = aws_subnet.public-subnet-1.id
}


# route table association with public subnet
resource "aws_route_table_association" "private-subnet-1-association" {
  route_table_id  = aws_route_table.private-route-table.id
  subnet_id       = aws_subnet.private-subnet-1.id
}

# creation of elastic ip for NAT gateway
resource "aws_eip" "elastic-ip-for-nat-gw" {
  vpc                       = true
  associate_with_private_ip = 10.0.0.5

  tags {
    Name = "Production-EIP"
  }
}

# creation of NAT gateway and allocating the EIP
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.elastic-ip-for-nat-gw.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags {
    Name = "Production-NAT-GW"
  }

  depends_on = ["aws_eip.elastic-ip-for-nat-gw"]
}

#Associating private route table to nat gateway
resource "aws_route" "nat-gw-route" {
  route_table_id          = aws_route_table.private-route-table.id
  nat_gateway_id          = aws_nat_gateway.nat-gw.id
  destination_cidr_block  = 0.0.0.0/0
}


# creation of Internet gateway
resource "aws_internet_gateway" "production-igw" {
  vpc_id = aws_vpc.production-vpc.id

  tags {
    Name = "Production-IGW"
  }
}

# Associating the public subnet with internet gateway
resource "aws_route" "public-internet-gw-route" {
  route_table_id          = aws_route_table.public-route-table.id
  gateway_id              = aws_internet_gateway.production-igw.id
  destination_cidr_block  = 0.0.0.0/0
}

