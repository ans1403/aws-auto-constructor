##### VPC #####

resource "aws_vpc" "default" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.environment
  }
}


##### Internet Gateway #####

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = var.environment
  }
}


##### Public Route Table #####

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "${var.environment}-public"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.default.id
  destination_cidr_block = "0.0.0.0/0"
}


##### Private Route Table #####

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "${var.environment}-private"
  }
}
