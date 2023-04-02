variable "dl_s3_raw" {
  description = "The information for the S3 raw data bucket"
  type = object({
    bucket_name            = string
    block_public_acls      = bool
    block_public_policy    = bool
    force_destroy          = bool
    lifecycle_rule         = any # or a more specific type
    restrict_public_buckets = bool
    versioning             = map(string) # Update the versioning type
    create_s3_bucket       = bool # Add the create_s3_bucket attribute
    
  })
}

# Add any other attributes you need

variable "tags" {
  description = "A map of tags to apply to resources"
  type        = map(string)
  default     = {}
}
