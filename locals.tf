locals {
  vpc_id = var.use_dynamic_vpc_id ? data.aws_vpc.selected.id : var.vpc_id
  gateway_id = var.use_dynamic_gateway_id ? data.aws_nat_gateway.selected.id : var.gateway_id
}
