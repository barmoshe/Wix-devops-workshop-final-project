terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~>1.14"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "--region", var.region, "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

