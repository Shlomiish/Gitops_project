resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "MyVPC"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "MyInternetGateway"
  }
}




//// Create Subnets (private and public) ////

# Public Subnet 1
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = var.azs[0]
  map_public_ip_on_launch = true
   tags = {
    Name = "MyPublicSubnet1"
    "kubernetes.io/role/elb" = "1" //Tells the ALB to use that public subnet, 1 means true (bool)
  }
}

# Public Subnet 2
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[1]
  availability_zone       = var.azs[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "MyPublicSubnet2"
    "kubernetes.io/role/elb" = "1" //Tells the ALB to use that public subnet, 1 means true (bool)
  }
}

# Private Subnet 1
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = var.azs[0]
  tags = {
    Name = "MyPrivateSubnet1"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Private Subnet 2
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[1]
  availability_zone = var.azs[1]
  tags = {
    Name = "MyPrivateSubnet2"
    "kubernetes.io/role/internal-elb" = "1"
  }
}
////////////////////////////////////////////




//// Create Nat gateway and Elastic IP ////

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  tags = {
    Name = "MyNATGatewayEIP"
  }
}

# NAT Gateway (connected to both public subnets)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  //subnet_id     = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "MyNATGateway"
  }
}
////////////////////////////////////////////




//// Create Route table ////

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "MyPublicRouteTable"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "MyPrivateRouteTable"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}
///////////////////////////////////////////




//// Associate the IP's to the route tables ////

# Associate Public Subnet 1 with Route Table
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# Associate Public Subnet 2 with Route Table
resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Associate Private Subnet 1 with Route Table
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

# Associate Private Subnet 2 with Route Table
resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}
