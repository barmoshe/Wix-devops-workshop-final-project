variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "The AWS region in which to create resources."
}

variable "vpc_id" {
  type    = string
  default = "vpc-33"
}
variable "use_dynamic_vpc_id" {
  type        = bool
  default     = true
  description = "Set to true if you want to dynamically get the VPC ID by name."
}
locals {
  vpc_id = var.use_dynamic_vpc_id ? data.aws_vpc.selected.id : var.vpc_id
}
variable "cidr_1" {
  type    = string
  default = "192.168.24.0/24"
}
variable "cidr_2" {
  type    = string
  default = "192.168.25.0/24"
}
