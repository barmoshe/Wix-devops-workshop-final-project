variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "The AWS region in which to create resources."
}

variable "vpc_id" {
  type    = string
  default = "vpc-01b834daa2d67cdaa"
}
variable "gateway_id" {
  type    = string
  default = "nat-0a1b2c3d4e5f6g7h8"
}

variable "use_dynamic_vpc_id" {
  type        = bool
  default     = true
  description = "Set to true if you want to dynamically get the VPC ID by name."
}
variable "use_dynamic_gateway_id" {
  type        = bool
  default     = true
  description = "Set to true if you want to dynamically get the NAT Gateway ID by name."
}

variable "cidr_1" {
  type    = string
  default = "192.168.24.0/24"
}

variable "cidr_2" {
  type    = string
  default = "192.168.25.0/24"
}
variable "iam_user_names" {
  type        = list(string)
  description = "The names of the IAM users to grant access to the S3 bucket and EKS cluster."
  default     = ["barm-user", "shaiga", "yehiamc", "esterh"]
}


variable "cluster_version" {
  type    = string
  default = "1.29"
}
variable "cluster_name" {
  type    = string
  default = "barm-cluster"
}
variable "hosted_zone_id" {
  type        = string
  description = "Route 53 Hosted Zone ID for wix-devops-workshop.com"
  default     = "Z00269823B8KU0UBQVXPI"
}
