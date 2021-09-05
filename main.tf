locals {
  environment = "production"
  vpc = {
    cidr_block = "10.0.0.0/16"
  }
  alb = {
    subnets = [
      {
        availability_zone = "ap-northeast-1a"
        cidr_block        = "10.0.0.0/24"
      },
      {
        availability_zone = "ap-northeast-1c"
        cidr_block        = "10.0.1.0/24"
      }
    ]
    health_check_path    = "/"
    health_check_matcher = 200
  }
  bastion = {
    availability_zone  = "ap-northeast-1a"
    cidr_block         = "10.0.10.0/24"
    key_name           = "bastion"
    ssh_permitted_cidr = var.bastion_ssh_permitted_cidr
  }
  ec2 = {
    instance_type = "t2.micro"
    instances = [
      {
        availability_zone = "ap-northeast-1a"
        cidr_block        = "10.0.20.0/24"
        key_name          = "server01"
      },
      {
        availability_zone = "ap-northeast-1c"
        cidr_block        = "10.0.21.0/24"
        key_name          = "server02"
      }
    ]
  }
  rds = {
    instance_class  = "db.t3.small"
    master_username = var.db_user
    master_password = var.db_password
    subnets = [
      {
        availability_zone = "ap-northeast-1a"
        cidr_block        = "10.0.30.0/24"
      },
      {
        availability_zone = "ap-northeast-1c"
        cidr_block        = "10.0.31.0/24"
      }
    ]
  }
}

module "vpc" {
  source      = "./modules/vpc"
  environment = local.environment
  cidr_block  = local.vpc.cidr_block
}

module "security_group" {
  source                     = "./modules/security_group"
  vpc_id                     = module.vpc.id
  environment                = local.environment
  bastion_ssh_permitted_cidr = local.bastion.ssh_permitted_cidr
}

module "alb" {
  source               = "./modules/alb"
  vpc_id               = module.vpc.id
  route_table_id       = module.vpc.public_route_table_id
  security_group_id    = module.security_group.alb_security_group_id
  environment          = local.environment
  subnets              = local.alb.subnets
  health_check_path    = local.alb.health_check_path
  health_check_matcher = local.alb.health_check_matcher
}

module "bastion_key" {
  source   = "./modules/key_pair"
  key_name = local.bastion.key_name
}

module "bastion" {
  source            = "./modules/bastion"
  vpc_id            = module.vpc.id
  route_table_id    = module.vpc.public_route_table_id
  security_group_id = module.security_group.ec2_bastion_security_group_id
  environment       = local.environment
  availability_zone = local.bastion.availability_zone
  cidr_block        = local.bastion.cidr_block
  key_name          = local.bastion.key_name
}

module "ec2_key" {
  count    = length(local.ec2.instances)
  source   = "./modules/key_pair"
  key_name = local.ec2.instances[count.index].key_name
}

module "ec2" {
  source               = "./modules/ec2"
  count                = length(local.ec2.instances)
  vpc_id               = module.vpc.id
  route_table_id       = module.vpc.public_route_table_id
  security_group_id    = module.security_group.ec2_security_group_id
  alb_target_group_arn = module.alb.target_group_arn
  environment          = local.environment
  instance_type        = local.ec2.instance_type
  availability_zone    = local.ec2.instances[count.index].availability_zone
  cidr_block           = local.ec2.instances[count.index].cidr_block
  key_name             = local.ec2.instances[count.index].key_name
  index                = count.index
}

module "rds" {
  source            = "./modules/rds"
  vpc_id            = module.vpc.id
  route_table_id    = module.vpc.private_route_table_id
  security_group_id = module.security_group.rds_security_group_id
  environment       = local.environment
  instance_class    = local.rds.instance_class
  subnets           = local.rds.subnets
  master_username   = local.rds.master_username
  master_password   = local.rds.master_password
}
