locals {
  # Buckets account-regional precisam do sufixo account-region-an.
  bucket_name = "${var.bucket_name_prefix}-${data.aws_caller_identity.current.account_id}-${var.aws_region}-an"
}
