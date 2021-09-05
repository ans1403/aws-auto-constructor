##### ALB Subnets #####

resource "aws_subnet" "alb" {
  count                   = length(var.subnets)
  vpc_id                  = var.vpc_id
  availability_zone       = var.subnets[count.index].availability_zone
  cidr_block              = var.subnets[count.index].cidr_block
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-alb-${count.index}"
  }
}

resource "aws_route_table_association" "alb" {
  count          = length(aws_subnet.alb)
  subnet_id      = aws_subnet.alb[count.index].id
  route_table_id = var.route_table_id
}


##### ALB #####

resource "aws_lb" "default" {
  name               = var.environment
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = toset([for x in aws_subnet.alb : x.id])
}


##### Target Group #####

resource "aws_lb_target_group" "default" {
  name     = var.environment
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path    = var.health_check_path
    matcher = var.health_check_matcher
  }
}


##### Relation with ALB and Target Group #####

resource "aws_alb_listener" "default" {
  load_balancer_arn = aws_lb.default.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.default.arn
    type             = "forward"
  }
}
