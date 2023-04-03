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
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.60.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}

module "dl_s3_raw" {
  source = "terraform-aws-modules/s3-bucket/aws"

  block_public_acls       = var.dl_s3_raw.block_public_acls
  block_public_policy     = var.dl_s3_raw.block_public_policy
  bucket                  = var.dl_s3_raw.bucket_name
  count                   = var.dl_s3_raw.create_s3_bucket ? 1 : 0
  force_destroy           = var.dl_s3_raw.force_destroy
  lifecycle_rule          = var.dl_s3_raw.lifecycle_rule
  restrict_public_buckets = var.dl_s3_raw.restrict_public_buckets
  versioning              = var.dl_s3_raw.versioning
  tags                    = var.tags

}
