dl_s3_raw = {
  block_public_acls       = true
  block_public_policy     = true
  bucket_name             = "raw"
  create_s3_bucket        = true
  force_destroy           = true
  restrict_public_buckets = true
  versioning             = { "status" = "Enabled" } # Update the versioning value
  lifecycle_rule = [{
    id      = "dl-s3-raw-transition"
    enabled = true

 tags = {
  "Environment" = "dev"
  # Add any other tags you want to apply
}
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
