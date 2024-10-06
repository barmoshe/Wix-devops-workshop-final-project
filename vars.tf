variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "The AWS region in which to create resources."
}

variable "vpc_id" {
  type    = string
  default = "vpc-01b834daa2d67cdaa"
}

variable "cidr_1" {
  type    = string
  default = "192.168.24.0/24"
}
variable "cidr_2" {
  type    = string
  default = "192.168.25.0/24"
}
