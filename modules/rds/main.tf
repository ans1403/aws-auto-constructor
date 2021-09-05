locals {
  engine                   = "aurora-mysql"
  engine_version           = "5.7.mysql_aurora.2.07.2"
  cluster_parameter_family = "aurora-mysql5.7"
}

##### RDS Subnet #####

resource "aws_subnet" "rds" {
  count                   = length(var.subnets)
  vpc_id                  = var.vpc_id
  availability_zone       = var.subnets[count.index].availability_zone
  cidr_block              = var.subnets[count.index].cidr_block
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.environment}-rds-${count.index}"
  }
}

resource "aws_route_table_association" "rds" {
  count          = length(aws_subnet.rds)
  subnet_id      = aws_subnet.rds[count.index].id
  route_table_id = var.route_table_id
}


##### DB Subnet Group #####

resource "aws_db_subnet_group" "default" {
  name       = var.environment
  subnet_ids = [for v in aws_subnet.rds : v.id]
}


##### RDS Cluster Parameter Group #####

resource "aws_rds_cluster_parameter_group" "default" {
  name   = var.environment
  family = local.cluster_parameter_family

  parameter {
    name         = "character_set_client"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_connection"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_database"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_results"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_server"
    value        = "utf8mb4"
    apply_method = "immediate"
  }
}


##### RDS Cluster #####

resource "aws_rds_cluster" "default" {
  cluster_identifier              = var.environment
  engine                          = local.engine
  engine_version                  = local.engine_version
  vpc_security_group_ids          = [var.security_group_id]
  db_subnet_group_name            = aws_db_subnet_group.default.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.default.name
  master_username                 = var.master_username
  master_password                 = var.master_password
  skip_final_snapshot             = true
  apply_immediately               = true
}


##### RDS Cluster Instance #####

resource "aws_rds_cluster_instance" "default" {
  count                = 2
  cluster_identifier   = aws_rds_cluster.default.id
  engine               = aws_rds_cluster.default.engine
  engine_version       = aws_rds_cluster.default.engine_version
  db_subnet_group_name = aws_rds_cluster.default.db_subnet_group_name
  instance_class       = var.instance_class
}
