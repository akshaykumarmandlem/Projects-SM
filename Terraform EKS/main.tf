terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.13.1"
    }
  }
}

# VPC Module
module "vpc" {
  source  = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=26c38a66f12e7c6c93b6a2ba127ad68981a48671"  # commit hash of version 5.0.0

  name                 = "eks-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway    = true
  single_nat_gateway    = true
}

# EKS Module
module "eks" {
  source                = "terraform-aws-modules/eks/aws"
  version               = "20.26.0"  # Updated to the correct EKS module
  cluster_name          = "Project"
  cluster_version       = "1.30"  # Specify the desired Kubernetes version
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnets

  eks_managed_node_groups = {
    eks_nodes = {                       # name of the worker-group
      desired_size   = 2                # Desired count set to 2
      max_size       = 4                 # Maximum count set to 4
      min_size       = 2                 # Minimum count set to 2
      instance_types = ["t3.micro"]
      capacity_type  = "SPOT"
    }
  }

  enable_irsa = true
}

# Security Group for EKS
resource "aws_security_group" "eks_security_group" {
  name        = "eks_security_group"
  description = "EKS security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80 
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Consider restricting to trusted IPs
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Consider restricting to trusted IPs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks_security_group"
  }
}

# Key Pair for EC2 Instance
resource "aws_key_pair" "ProjectKey" {
  key_name   = "ProjectKey"
  public_key = file(".sec/ProjectKey.pub")
}
  
# Data Source for Latest AMI
data "aws_ami" "latest_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# EC2 Instance Configuration
resource "aws_instance" "my_instance" {
  ami                    = data.aws_ami.latest_ami.id
  instance_type         = "t2.micro"
  key_name              = aws_key_pair.ProjectKey.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id             = module.vpc.public_subnets[0]

  user_data = base64encode(
    templatefile("${path.module}/template.tpl", {
      host_port      = 8080
      container_port = 80
      container_name = "nginx",
      image          = "nginx:latest"
    })
  )

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
    encrypted   = true
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = {
    Name = "Project_Instance"
  }
}

# Security Group for SSH Access
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Consider restricting to trusted IPs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}