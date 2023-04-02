# Require TF version to be same as or greater than 0.12.13
terraform {
  required_version = ">=1.4.4"
  #backend "s3" {
  #  bucket         = "kyler-github-actions-demo-terraform-tfstate"
  #  key            = "terraform.tfstate"
  #  region         = "us-east-1"
  #  dynamodb_table = "aws-locks"
  #  encrypt        = true
  #}
}

# Download any stable version in AWS provider of 2.36.0 or higher in 2.36 train
provider "aws" {
  region  = "us-east-1"
  version = "~> 2.36.0"
}

module "dl_s3_raw" {
  source = "terraform-aws-modules/s3-bucket/aws"

  block_public_acls       = var.dl_s3_raw.block_public_acls
  block_public_policy     = var.dl_s3_raw.block_public_policy
  bucket_name             = var.dl_s3_raw.bucket_name
  create_s3_bucket        = var.dl_s3_raw.create_s3_bucket
  force_destroy           = var.dl_s3_raw.force_destroy
  kms_master_key_arn      = module.dl_kms.kms_arn
  lifecycle_rule          = var.dl_s3_raw.lifecycle_rule
  restrict_public_buckets = var.dl_s3_raw.restrict_public_buckets
  sse_algorithm           = var.dl_s3_raw.sse_algorithm
  sse_prevent             = var.dl_s3_raw.sse_prevent
  versioning              = var.dl_s3_raw.versioning
  tags                    = var.tags

  depends_on = [module.dl_kms]
}

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
