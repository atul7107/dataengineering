variable "dl_s3_raw" {
  description = "The information for the S3 raw data bucket"
  type = object({
    bucket_name            = string
    block_public_acls      = bool
    block_public_policy    = bool
    force_destroy          = bool
    restrict_public_buckets = bool
    versioning             = map(string) # Update the versioning type
    create_s3_bucket       = bool # Add the create_s3_bucket attribute
    lifecycle_rule          = list(object({
      id         = string
      enabled    = bool
      transition = list(object({
        days          = number
        storage_class = string
      }))
      expiration = list(object({
        days = number
      }))
    }))
  })
}

variable "dl_glue_job_raw_to_prepared" {
  type = object({
    type            = string
    name            = string
    scripts_folder  = string
    temp_folder     = string
    job_bookmark_option = string
    origin_db       = string
    glue_version    = string
    number_of_workers = number
    worker_type      = string
    timeout          = number
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

# Define the input variables for module "dl_s3_internal"
variable "dl_s3_internal_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for storing raw data"
}

# Define the input variables for module "dl_s3_prepared"
variable "dl_s3_prepared_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for storing prepared data"
}

variable "dl_s3_prefixes" {
  type    = list(string)
  default = []
}

variable "acl" {
  description = "Access control list for S3 bucket"
  type        = string
  default     = "private"
}

variable "dl_s3_internal_lifecycle_rule" {
  description = "The lifecycle rules for the dl_s3_internal bucket"
  type        = list(any)
  default     = []
}

variable "dl_glue_raw_db" {
  description = "The name of the Glue raw database"
  type        = string
  default     = "dl_glue_raw_db" # Replace this with a default database name or remove the line if you want to make it required
}


variable "region_availability_zones" {
  description = "List of availability zones in the region"
  type        = list(string)
  default     = [] # You can provide default availability zones or leave it empty
}

variable "server_side_encryption_configuration" {
  description = "The server-side encryption configuration for the S3 bucket"
  type        = map(any)
  default = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}
