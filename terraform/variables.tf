variable "aws_region" {
  description = "Região AWS onde a aplicação será criada."
  type        = string
  default     = "us-east-2"
}

variable "bucket_name_prefix" {
  description = "Prefixo do bucket de armazenamento das URLs."
  type        = string
  default     = "url-shortener-storage"
}

data "aws_caller_identity" "current" {}
