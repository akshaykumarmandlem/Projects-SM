terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.66.0"
    }
  }
}
provider "aws" {
  region = "us-east-2"  # Replace with your desired region/ US East Ohio
  access_key = var.aws_access_key  # Replace with your AWS access key
  secret_key = var.aws_secret_key  # Replace with your AWS secret key
}

# Create a new key pair for EC2 instance access
resource "aws_key_pair" "my_key" {
  key_name   = "VsKey"
  public_key = file("./.sec/VsKey.pub")  # Path to your public SSH key
}
# Create a security group
resource "aws_security_group" "allow_8080" {
  name        = "VsCode_Security_Group"
  description = "Allow incoming traffic on port 8080"

  # Allow inbound HTTP traffic on port 8080
  ingress {
    description = "Open port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow inbound SSH traffic on port 22 (Limit access for security reasons)
  ingress {
    description = "Open port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace this with your public IP for better security
  }
  ingress {
    description = "Open port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  #tfsec:ignore:egress
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Create an SSM parameter
resource "aws_ssm_parameter" "github_token" {
  name  = "github_token"
  type  = "SecureString"
  value = var.github_token # Replace with your actual GitHub token
}

# Create IAM role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}
# Fetch the latest AMI
data "aws_ami" "latest_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
resource "aws_instance" "my_instance" {
  ami           = data.aws_ami.latest_ami.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name

  vpc_security_group_ids = [aws_security_group.allow_8080.id]

  user_data = base64encode(
    templatefile("${path.module}/template.tpl", {
      github_token = aws_ssm_parameter.github_token.value
      host_port = 8080
      container_port = 80
      container_name = "nginx",
      image = "nginx:latest"
      }
    )
  )
  # Encrypt the root block device
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8   # You can adjust the size
    encrypted             = true  # Enable encryption
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = {
    Name = "Terraform-EC2-new"
  }
}
