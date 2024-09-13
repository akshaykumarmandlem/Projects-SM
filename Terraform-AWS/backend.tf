# Define the S3 bucket
resource "aws_s3_bucket" "vscode-mak" {
  bucket = "vscode-mak"  # Ensure this bucket name is globally unique

  tags = {
    Name = "vscode"
  }
}

# Define server-side encryption configuration for the bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "vscode-mak" {
  bucket = aws_s3_bucket.vscode-mak.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"  # Use customer-managed key
      kms_master_key_id = aws_kms_key.vscode_kms.id
    }
  }
}

# Define versioning for the bucket
resource "aws_s3_bucket_versioning" "vscode-mak" {
  bucket = aws_s3_bucket.vscode-mak.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Define public access block policy for the bucket
resource "aws_s3_bucket_public_access_block" "vscode-mak_block_policy" {
  bucket = aws_s3_bucket.vscode-mak.id

  block_public_acls   = true
  ignore_public_acls  = true
  block_public_policy = true
  restrict_public_buckets = true
}

# Create a logging target S3 bucket
resource "aws_s3_bucket" "vscode-mak_logs" {
  bucket = "vscode-mak-logs"  # Ensure this bucket name is globally unique
}

# Create a KMS Key for customer-managed encryption
resource "aws_kms_key" "vscode_kms" {
  description         = "KMS key for encrypting S3 bucket data"
  enable_key_rotation = true
}