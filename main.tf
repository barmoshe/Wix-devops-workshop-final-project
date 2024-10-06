resource "aws_subnet" "barm-terraform-subnet-1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.cidr_1
  availability_zone = "${var.region}a"
  tags = {
    Name = "barm-terraform-subnet-1"
  }



}
