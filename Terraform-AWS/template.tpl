#!/bin/bash
# Log user data execution
exec > /var/log/user-data.log 2>&1

# Specify default region for AWS CLI
AWS_REGION="us-east-2"  # Change this to your preferred AWS region
aws configure set default.region $AWS_REGION

# Update system packages
yum update -y

# Install necessary packages: docker, git, unzip
yum install -y docker git

# Enable and start Docker service
systemctl enable docker
systemctl start docker

# Add ec2-user to the docker group to avoid using sudo for Docker commands
usermod -aG docker ec2-user

# Retrieve GitHub token from AWS SSM Parameter Store
github_token=$(aws ssm get-parameter --name="github_token" --with-decryption --query "Parameter.Value" --output text --region $AWS_REGION)

# GitHub repository details
REPO_URL="https://github.com/akshaykumarmandlem/Projects-SM"
CLONE_DIR="/home/ec2-user/Projects-SM"

# Check if GitHub token was retrieved successfully
if [ -z "$github_token" ]; then
    echo "Error: Failed to retrieve GitHub token from SSM."
    exit 1
fi

# Create the directory for the repository clone if it doesn't exist
mkdir -p $CLONE_DIR

# Clone the GitHub repository using the retrieved token
if git clone https://${github_token}@github.com/akshaykumarmandlem/Projects-SM.git $CLONE_DIR; then
    echo "Repository cloned successfully."
else
    echo "Error: Failed to clone repository."
    exit 1
fi

# Navigate to the Flask app project directory
cd $CLONE_DIR/Flask_App || { echo "Error: Project directory not found."; exit 1; }

# Build Docker image for the Flask app
if docker build -t website .; then
    echo "Docker image built successfully."
else
    echo "Error: Failed to build Docker image."
    exit 1
fi

# Run the Docker container on port 8080
if docker run -d --name website -p 8080:8080 website; then
    echo "Docker container started successfully."
else
    echo "Error: Failed to start Docker container."
    exit 1
fi

echo "Setup complete."