# # # Define IAM policy document for AWS LBC
# # data "aws_iam_policy_document" "aws_lbc" {
# #   statement {
# #     effect = "Allow"

# #     principals {
# #       type        = "Service"
# #       identifiers = ["pods.eks.amazonaws.com"]
# #     }

# #     actions = [
# #       "sts:AssumeRole",
# #       "sts:TagSession"
# #     ]
# #   }
# # }

# # # Define IAM role for AWS LBC
# # resource "aws_iam_role" "aws_lbc" {
# #   name               = "${var.cluster_name}-aws-lbc"
# #   assume_role_policy = data.aws_iam_policy_document.aws_lbc.json
# # }



# # # Attach IAM policy to the IAM role
# # resource "aws_iam_role_policy_attachment" "aws_lbc" {
# #   policy_arn = aws_iam_policy.aws_lbc.arn
# #   role       = aws_iam_role.aws_lbc.name
# # }

# # # Associate IAM role with the EKS pod in the kube-system namespace
# # resource "aws_eks_pod_identity_association" "aws_lbc" {
# #   cluster_name    = var.cluster_name
# #   namespace       = "kube-system"
# #   service_account = "aws-load-balancer-controller"
# #   role_arn        = aws_iam_role.aws_lbc.arn
# # }

# # # Deploy AWS Load Balancer Controller using Helm
# # resource "helm_release" "aws_lbc" {
# #   name       = "aws-load-balancer-controller"
# #   repository = "https://aws.github.io/eks-charts"
# #   chart      = "aws-load-balancer-controller"
# #   namespace  = "kube-system"
# #   version    = "1.7.2"

# #   set {
# #     name  = "clusterName"
# #     value = var.cluster_name
# #   }

# #   set {
# #     name  = "serviceAccount.name"
# #     value = "aws-load-balancer-controller"
# #   }

# #   depends_on = [aws_iam_role_policy_attachment.aws_lbc]
# # }
# # Retrieve existing IAM policy
# data "aws_iam_policy" "lb_controller_policy" {
#   arn = "arn:aws:iam::730335218716:policy/AWSLoadBalancerControllerIAMPolicy"  # Replace with the ARN of your existing policy
# }

# # Attach existing IAM policy to the IAM role
# resource "aws_iam_role_policy_attachment" "lb_controller_attachment" {
#   policy_arn = data.aws_iam_policy.lb_controller_policy.arn
#   role       = aws_iam_role.lb_controller_role.name
# }

# data "aws_iam_policy_document" "lb_controller_policy" {
#   statement {
#     actions = [
#       "ec2:Describe*",
#       "ec2:CreateSecurityGroup",
#       "ec2:DeleteSecurityGroup",
#       "ec2:AuthorizeSecurityGroupIngress",
#       "ec2:RevokeSecurityGroupIngress",
#     ]
#     resources = ["*"]
#   }
# }


# # Create IAM role and attach the policy
# resource "aws_iam_role" "lb_controller_role" {
#   name               = "eks-lb-controller-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Service = "eks.amazonaws.com"
#       }
#       Action = "sts:AssumeRole"
#     }]
#   })
# }


# resource "helm_release" "aws_lb_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"

#   values = [
#     <<EOF
# clusterName: "${var.cluster_name}" # Name of your EKS cluster
# region: "${var.region}"            # Region of your EKS cluster
# vpcId: "${var.vpc_id}"             # VPC ID where the EKS cluster is running

# serviceAccount:
#   create: false                    # Set to true if creating the Service Account via Helm
#   name: aws-lb-controller

# image:
#   tag: v2.4.7                      # Replace with the latest controller version

# EOF
#   ]

#   set {
#     name  = "serviceAccount.annotations.eks.amazonaws.com/role-arn"
#     value = aws_iam_role.lb_controller_role.arn
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.lb_controller_attachment
#   ]
# }
# Create the service account with annotation
# resource "kubernetes_service_account" "aws_load_balancer_controller" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = "arn:aws:iam::730335218716:role/lb-controller-role-workshop-cluster"
#     }
#   }
# }


# # Deploy the AWS Load Balancer Controller
# resource "helm_release" "aws_load_balancer_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts" # Directly use the repository URL
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"

#   set {
#     name  = "clusterName"
#     value = "barm-cluster"
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "false"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }

#   set {
#     name  = "region"
#     value = "eu-west-1"
#   }

#   depends_on = [kubernetes_service_account.aws_load_balancer_controller]
# }