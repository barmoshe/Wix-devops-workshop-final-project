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


resource "aws_eks_access_policy_association" "user_access" {
  for_each = toset(var.iam_user_names)

  cluster_name  = var.cluster_name
  principal_arn = data.aws_iam_user.current_users[each.key].arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
  depends_on = [module.eks]

}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.0"


  cluster_addons = {
    aws-ebs-csi-driver = {
      addon_version = "v1.35.0-eksbuild.1"

    }
    coredns = {
      addon_version = "v1.11.3-eksbuild.1"
    }
    # vpc-cni = {
    #   addon_version = "v1.18.5-eksbuild.1"
    # }
  }


  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id = local.vpc_id
  subnet_ids = [
    aws_subnet.barm-terraform-subnet-1.id,
    aws_subnet.barm-terraform-subnet-2.id
  ]
  cluster_endpoint_public_access = true

  cluster_security_group_additional_rules = {
    allow_https = {
      description = "Allow inbound HTTPS traffic from trusted IPs"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      type        = "ingress"
      cidr_blocks = [aws_subnet.barm-terraform-subnet-1.cidr_block, aws_subnet.barm-terraform-subnet-2.cidr_block]
    }
  }
  eks_managed_node_group_defaults = {
    instance_types = [" t2.small "]
  }

  eks_managed_node_groups = {
    barm_nodegroup = {
      desired_size   = 2
      min_size       = 1
      max_size       = 3
      instance_types = ["t2.small"]
    }
  }

  access_entries = { for user_name in var.iam_user_names :
    user_name => {
      principal_arn = data.aws_iam_user.current_users[user_name].arn
    }
  }
  tags = {
    Environment = "barm-devops"
    Name        = "barm-devops-cluster"
  }
}
# #Create the NGINX Deployment
# resource "kubernetes_deployment_v1" "nginx_deployment" {
#   metadata {
#     name = "nginx-deployment"
#     labels = {
#       app = "nginx"
#     }
#   }
#   spec {
#     replicas = 2
#     selector {
#       match_labels = {
#         app = "nginx"
#       }
#     }
#     template {
#       metadata {
#         labels = {
#           app = "nginx"
#         }
#       }
#       spec {
#         container {
#           name  = "nginx"
#           image = "nginx:1.21.6"
#           port {
#             container_port = 80
#           }
#         }
#       }
#     }
#   }
# }

# #Create the Service with ACM certificate
# resource "kubernetes_service" "nginx_service" {
#   metadata {
#     name = "nginx-service"
#     annotations = {
#       "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"         = "arn:aws:acm:eu-west-1:730335218716:certificate/8f4eeeea-9a1d-443c-a8c8-4de7f8b19aec"
#       "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "http"
#       "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"        = "443"
#       "service.beta.kubernetes.io/aws-load-balancer-type"             = "alb"
#     }
#   }

#   spec {
#     type = "LoadBalancer"
#     selector = {
#       app = "nginx"
#     }
#     port {
#       port        = 443
#       target_port = 80
#       protocol    = "TCP"
#     }
#   }
# }


# # Route 53 DNS Record for barm.wix-devops-workshop.com
# resource "aws_route53_record" "nginx_dns" {
#   zone_id = var.hosted_zone_id
#   name    = "barm.wix-devops-workshop.com"
#   type    = "CNAME"

#   records = [kubernetes_service.nginx_service.status[0].load_balancer[0].ingress[0].hostname]
#   ttl     = 60

#   depends_on = [kubernetes_service.nginx_service]
# }
