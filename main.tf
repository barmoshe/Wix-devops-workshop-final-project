resource "aws_subnet" "barm-terraform-subnet-1" {
  vpc_id            = local.vpc_id
  cidr_block        = var.cidr_1
  availability_zone = "${var.region}a"

  tags = {
    Name = "barm-terraform-subnet-1"
  }
}

resource "aws_subnet" "barm-terraform-subnet-2" {
  vpc_id            = local.vpc_id
  cidr_block        = var.cidr_2
  availability_zone = "${var.region}b"

  tags = {
    Name = "barm-terraform-subnet-2"
  }
}

# Create a route table
resource "aws_route_table" "route_table" {
  vpc_id = local.vpc_id

  tags = {
    Name = "barm-terraform-route-table"
  }
}

# Route table should include the existing NAT gateway
resource "aws_route" "nat_gateway_route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = data.aws_nat_gateway.selected.id
}

# Associate the two subnets with the route table
resource "aws_route_table_association" "subnet1_association" {
  subnet_id      = aws_subnet.barm-terraform-subnet-1.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet2_association" {
  subnet_id      = aws_subnet.barm-terraform-subnet-2.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = "barm-devops-bucket"

  policy = data.aws_iam_policy_document.bucket_policy.json
}



module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.0"

  # EKS cluster configuration
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # VPC and Subnets from the previous task
  vpc_id = local.vpc_id
  subnet_ids = [
    aws_subnet.barm-terraform-subnet-1.id,
    aws_subnet.barm-terraform-subnet-2.id
  ]

  eks_managed_node_groups = {
    barm_nodegroup = {
      desired_capacity = 2
      min_capacity     = 1
      max_capacity     = 3
      instance_type    = "t2.micro" # Set machine type to t2.micro
    }
  }

}

