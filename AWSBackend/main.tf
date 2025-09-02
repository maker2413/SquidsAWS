# --- backend/main.tf ---

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  tags = {
    Name    = var.bucket_name
    Module  = "backend"
    Project = "Squids"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "local_file" "backend" {
  filename = "${path.root}/../Terraform/backend.tf"
  content  = <<-EOF
# --- backend.tf ---

terraform {
  backend "s3" {
    bucket               = "${var.bucket_name}"
    encrypt              = true
    key                  = "squids-aws.tfstate"
    region               = "us-west-2"
  }
}
EOF

}
