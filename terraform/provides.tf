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
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.9.0"
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
# Ensure your Kubernetes provider is correctly configured
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "--region", var.region, "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

# Adjust the Helm provider to use the same authentication as the Kubernetes provider
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "--region", var.region, "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}
