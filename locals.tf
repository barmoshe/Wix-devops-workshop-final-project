locals {
  vpc_id = var.use_dynamic_vpc_id ? data.aws_vpc.selected.id : var.vpc_id
}
