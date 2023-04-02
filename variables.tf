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

variable "dl_zones" {
  description = "A list of availability zones for the deployment"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "dl_catalog_db" {
  description = "Information for the AWS Glue Catalog database"
  type = object({
    name        = string
    description = string
  })
}



