provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
     helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
  }
}


provider "kubernetes" { //The Kubernetes provider allows Terraform to interact with Kubernetes cluster.
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data) #secure communication between terraform, kubectl, API server
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" { //The helm provider it allows Terraform to deploy Helm charts to the EKS cluster 
  kubernetes {   //using the Kubernetes provider connection details
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data) #secure communication between terraform, helm
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

// Retrieving EKS Cluster Information

data "aws_eks_cluster" "eks" { // retrieves the EKS cluster URL (endpoint)
  name = module.eks.cluster_name
  depends_on = [ module.eks ]
}

data "aws_eks_cluster_auth" "eks" { // retrieves the authentication token required to access the Kubernetes API
  name = module.eks.cluster_name
  depends_on = [ module.eks ]
}



module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}



module "eks" {
  source = "./modules/eks"
  cluster_name = var.cluster_name
  vpc_id = module.vpc.vpc_id
  private_subnet_ids = [module.vpc.private_subnet_1_id, module.vpc.private_subnet_2_id]
  
}

module "deployment" {
  source = "./modules/deployment"
  cluster_name = var.cluster_name
  app_image = var.app_image
  cluster_auth_token = module.eks.cluster_auth_token
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_certificate_authority = module.eks.cluster_certificate_authority
  depends_on                   = [module.eks]
}