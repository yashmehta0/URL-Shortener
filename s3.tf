resource "aws_s3_bucket" "mapper_bucket" {
  bucket = var.mapper_bucket_name

  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 0
    enabled                                = true
    id                                     = "Expiration"
    expiration {
      days                         = 1
      expired_object_delete_marker = false
    }
  }
  website {
    index_document = "index.html"
  }
}
resource "aws_s3_bucket_public_access_block" "mapper_bucket_access" {
  bucket = aws_s3_bucket.mapper_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}