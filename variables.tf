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

# Define the AWS IAM role resource for Glue jobs
resource "aws_iam_role" "glue_jobs" {
  name = "glue-jobs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

# Define the AWS Glue security configuration resource for S3 encryption and decryption
resource "aws_glue_security_configuration" "s3_encrypt_decrypt" {
  name = "s3-encrypt-decrypt-config"

  encryption_configuration {
    s3_encryption_mode = "SSE-S3"
  }

  s3_encryption {
    enable_s3_encryption = true
  }
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


