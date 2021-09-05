locals {
  ami           = "ami-0df99b3a8349462c6"
  instance_type = "t2.micro"
}

##### EC2 Bastion Subnet #####

resource "aws_subnet" "bastion" {
  vpc_id                  = var.vpc_id
  availability_zone       = var.availability_zone
  cidr_block              = var.cidr_block
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-bastion"
  }
}

resource "aws_route_table_association" "bastion" {
  subnet_id      = aws_subnet.bastion.id
  route_table_id = var.route_table_id
}


##### EC2 Bastion #####

resource "aws_instance" "bastion" {
  ami                    = local.ami
  instance_type          = local.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.bastion.id
  vpc_security_group_ids = [var.security_group_id]
  tags = {
    Name = "${var.environment}-bastion"
  }
}
