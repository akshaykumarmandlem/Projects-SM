# Terraform AWS S3 Bucket with KMS Encryption

This Terraform project provisions an S3 bucket with versioning, server-side encryption using a customer-managed AWS KMS key, and a public access block. It also sets up logging to a separate S3 bucket.

## Features
- S3 bucket with server-side encryption using AWS KMS.
- Versioning enabled for the S3 bucket.
- Public access is blocked to the S3 bucket.
- Logging to a dedicated S3 logging bucket.
- Use of a customer-managed KMS key for enhanced security.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed.
- AWS account with the necessary permissions for S3 and KMS.
- AWS credentials configured in your environment.

## Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>

2.	Initialize the Terraform project:
terraform init

3.	Review the resources that Terraform will create:
terraform plan

4. Apply the resources:
terraform apply

5. Cleanup the resources:
terraform destroy

NOTE:

### Instructions:
1. Replace the repo URLs and repo directory with your actual repository URL and directory name.
2. Modify the variables section if needed, depending on your configuration.
