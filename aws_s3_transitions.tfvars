dl_s3_raw = {
  block_public_acls       = true
  block_public_policy     = true
  bucket_name             = "raw"
  create_s3_bucket        = true
  force_destroy           = true
  restrict_public_buckets = true
  sse_algorithm           = "aws:kms"
  sse_prevent             = true
  versioning              = true
  lifecycle_rule = [{
    id      = "dl-s3-raw-transition"
    enabled = true

    transition = [
      {
        days          = 30
        storage_class = "STANDARD_IA"
      },
      {
        days          = 60
        storage_class = "GLACIER"
      }
    ]

    expiration = [
      {
        days = 180
      }
    ]
  }]
}
