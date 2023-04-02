dl_s3_raw = {
  block_public_acls       = true
  block_public_policy     = true
  bucket_name             = "dataengineeringrawglabdev"
  create_s3_bucket        = true
  force_destroy           = true
  restrict_public_buckets = true
  versioning              = { "status" = "Enabled" }
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

tags = {
  "Environment" = "dev"
  # Add any other tags you want to apply
}

dl_glue_job_raw_to_prepared = {
}

dl_catalog_db = {
  name        = "dl_glue_raw"
  description = "this is the glue pipeline"
}
dl_s3_internal_bucket_name = {
}

dl_s3_prepared_bucket_name = {
}
