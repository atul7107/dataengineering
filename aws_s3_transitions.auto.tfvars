dl_s3_raw = {
  block_public_acls       = true
  block_public_policy     = true
  bucket_name             = "dataengineeringrawglabdev"
  create_s3_bucket        = true
  force_destroy           = true
  restrict_public_buckets = true
  versioning              = { "status" = "Enabled" }
}

tags = {
  "Environment" = "dev"
  # Add any other tags you want to apply
}

dl_glue_job_raw_to_prepared = {
  type               = "G1.X"                   # Glue Job type, e.g., G1.X or G2.X
  name               = "raw-to-prepared-job"    # The name of your AWS Glue Job
  scripts_folder     = "scripts/"               # Folder in the S3 bucket where Glue Job scripts are stored
  temp_folder        = "temp/"                  # Folder in the S3 bucket where Glue Job temporary data is stored
  job_bookmark_option = "job-bookmark-disable"  # AWS Glue Job bookmark option (e.g., "job-bookmark-disable", "job-bookmark-enable", or "job-bookmark-pause")
  origin_db          = "raw-data-db"            # The name of the source database for the Glue Job
  glue_version       = "2.0"                    # AWS Glue version (e.g., "1.0", "2.0", or "3.0")
  number_of_workers  = 2                        # Number of workers for the Glue Job
  worker_type        = "Standard"               # AWS Glue Job worker type (e.g., "Standard", "G.1X", or "G.2X")
  timeout            = 60                       # Timeout for the Glue Job in minutes
}


dl_catalog_db = {
  name        = "dl_glue_raw"
  description = "this is the glue pipeline"
}
dl_s3_internal_bucket_name = "internal"
dl_s3_prepared_bucket_name = "s3_prepared"
