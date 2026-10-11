resource "aws_s3_bucket" "url_storage" {
  bucket           = local.bucket_name
  bucket_namespace = "account-regional"
}

resource "aws_s3_bucket_public_access_block" "url_storage" {
  bucket = aws_s3_bucket.url_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "url_storage" {
  bucket = aws_s3_bucket.url_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }

    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_ownership_controls" "url_storage" {
  bucket = aws_s3_bucket.url_storage.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
