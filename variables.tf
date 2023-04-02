variable "dl_s3_raw" {
  description = "The information for the S3 raw data bucket"
  type = object({
    bucket_name = string
  })
}
