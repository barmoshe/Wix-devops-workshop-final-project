resource "aws_subnet" "barm-terraform-subnet-1" {
 vpc_id = local.vpc_id
   cidr_block        = var.cidr_1
  availability_zone = "${var.region}a"
  tags = {
    Name = "barm-terraform-subnet-1"
  }
}

resource "aws_subnet" "barm-terraform-subnet-2" {
   vpc_id = local.vpc_id
  cidr_block        = var.cidr_2
  availability_zone = "${var.region}b"
  tags = {
    Name = "barm-terraform-subnet-2"
  }
}
