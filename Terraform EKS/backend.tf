# Create a KMS key for S3 bucket encryption
resource "aws_kms_key" "s3_key" {
  description = "KMS key for S3 bucket encryption"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "*"
        },
        Action = "kms:*",
        Resource = "*"
      }
    ]
  })
}

# Logging target S3 bucket
resource "aws_s3_bucket" "logs" {
  bucket = "myfinalproject-1"
}

# Server-side encryption configuration using KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "logs_encryption" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm    = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.id  # Reference to KMS key
    }
  }
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

 versioning_configuration {
   # Enable versioning to keep multiple variants of objects in the bucket
   status = "Enabled"
   
   # Optionally, enable MFA Delete for added security
   # Uncomment the following line if you want to use MFA Delete
   # mfa_delete = "Enabled"
 }
}
# Lifecycle configuration for logs bucket
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "expire_logs"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

# Public access block policy for the logs bucket
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}