provider "aws" {
  region = "us-east-2"
}

# Declare the EKS cluster
resource "aws_eks_cluster" "project" {
  name     = "Project"  # Specify a name for your EKS cluster
  role_arn = aws_iam_role.eks_role.arn  # Reference your IAM role here
  version  = "1.30"  # Specify the desired Kubernetes version

  vpc_config {
    subnet_ids = module.vpc.private_subnets
  }
}

# Retrieve cluster details for Kubernetes provider
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.project.name  # Fix reference to the EKS cluster resource
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = aws_eks_cluster.project.name  # Fix reference to the EKS cluster resource
}

# Kubernetes Provider
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint  # Use data source to get endpoint
  token                  = data.aws_eks_cluster_auth.eks_auth.token  # Use auth data source
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)  # Fix access to CA cert
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint  # Use data source to get endpoint
    token                  = data.aws_eks_cluster_auth.eks_auth.token  # Use auth data source
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)  # Fix access to CA cert
  }
}