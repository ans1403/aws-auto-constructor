variable "vpc_id" {
  type = string
}

variable "route_table_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "subnets" {
  type = list(object({
    availability_zone = string
    cidr_block        = string
  }))
}

variable "master_username" {
  type = string
}

variable "master_password" {
  type = string
}
