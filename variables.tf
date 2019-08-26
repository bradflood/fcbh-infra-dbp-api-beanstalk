variable "region" {
  default = "us-east-1"
}

variable "amis" {
  type = "map"
}

variable "max_availability_zones" {
  default = "2"
}

variable "zone_id" {
  type        = "string"
  description = "Route53 Zone ID"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "solution_stack_name" {
  default = "64bit Amazon Linux 2018.03 v2.8.14 running PHP 7.2"
}