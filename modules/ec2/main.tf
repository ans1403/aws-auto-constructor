locals {
  ami = "ami-0df99b3a8349462c6"
}


##### EC2 Subnet #####

resource "aws_subnet" "ec2" {
  vpc_id                  = var.vpc_id
  availability_zone       = var.availability_zone
  cidr_block              = var.cidr_block
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-ec2-${var.index}"
  }
}

resource "aws_route_table_association" "ec2" {
  subnet_id      = aws_subnet.ec2.id
  route_table_id = var.route_table_id
}


##### EC2 #####

resource "aws_instance" "ec2" {
  ami                    = local.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.ec2.id
  vpc_security_group_ids = [var.security_group_id]
  tags = {
    Name = "${var.environment}-${var.index}"
  }
}


##### Attach EC2 for ALB Target Group #####

resource "aws_lb_target_group_attachment" "default" {
  target_group_arn = var.alb_target_group_arn
  target_id        = aws_instance.ec2.id
}
