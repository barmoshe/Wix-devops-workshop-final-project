# # # Import the existing IAM role
# # data "aws_iam_role" "lb_controller_role" {
# #   name = "lb-controller-role-workshop-cluster"
# # }

# # # Update the IAM role trust relationship
# # resource "aws_iam_role" "lb_controller_role" {
# #   name               = data.aws_iam_role.lb_controller_role.name
# #   assume_role_policy = file("trust-policy.json")  # Reference the local trust policy JSON file
# # }

# Create a Kubernetes namespace for the AWS Load Balancer Controller
resource "kubernetes_namespace" "aws_lb_controller" {
  metadata {
    name = "aws-lb-controller"
  }
}
# Create a Kubernetes service account annotated with the IAM role ARN
resource "kubernetes_service_account" "aws_lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = kubernetes_namespace.aws_lb_controller.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::730335218716:role/lb-controller-role-workshop-cluster"
    }
  }
}
# Install the AWS Load Balancer Controller via Helm
resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = kubernetes_namespace.aws_lb_controller.metadata[0].name
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.10.0"  # Specify the version you want to use

values = [
  yamlencode({
    clusterName    = var.cluster_name
    region         = var.region
    vpcId          = local.vpc_id
    serviceAccount = {
      create = false
      name   = kubernetes_service_account.aws_lb_controller.metadata[0].name
    }
  })
]


  depends_on = [kubernetes_service_account.aws_lb_controller]
}

module "iam_assumable_role_aws_lb" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.6.0"
  create_role                   = true
  role_name                     = "AWSLoadBalancerControllerIAMRole"
  provider_url                  = "oidc.eks.eu-west-1.amazonaws.com/id/CB48D841B6C897DECD2F2A84AF533554"
  role_policy_arns              = ["arn:aws:iam::730335218716:policy/AWSLoadBalancerControllerIAMPolicy"]
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:aws-lb-controller:aws-load-balancer-controller"
  ]

  tags = {
    Terraform   = "true"
  }
}
