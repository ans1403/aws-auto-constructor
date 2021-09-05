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

variable "subnets" {
  type = list(object({
    availability_zone = string
    cidr_block        = string
  }))
}

variable "health_check_path" {
  type = string
}

variable "health_check_matcher" {
  type = number
}
