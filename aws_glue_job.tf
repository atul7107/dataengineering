resource "aws_glue_job" "raw_to_prepared" {
     
  for_each = toset(var.dl_s3_prefixes)
  
  name                   = "${var.dl_glue_job_raw_to_prepared.name}_${each.key}"
  role_arn               = aws_iam_role.glue_jobs.arn
  security_configuration = aws_glue_security_configuration.s3_encrypt_decrypt.name
  glue_version           = var.dl_glue_job_raw_to_prepared.glue_version
  number_of_workers      = var.dl_glue_job_raw_to_prepared.number_of_workers
  worker_type            = var.dl_glue_job_raw_to_prepared.worker_type
  timeout                = var.dl_glue_job_raw_to_prepared.timeout

  command {
    script_location = "s3://${module.dl_s3_internal.s3_bucket_id}/${var.dl_glue_job_raw_to_prepared.scripts_folder}/${var.dl_glue_job_raw_to_prepared.name}.py"
  }

  default_arguments = {
    "--job-bookmark-option" : "${var.dl_glue_job_raw_to_prepared.job_bookmark_option}"
    "--TempDir"             : "s3://${module.dl_s3_internal.s3_bucket_id}/${var.dl_glue_job_raw_to_prepared.temp_folder}"
    "--DestBucket"          : "${module.dl_s3_prepared.s3_bucket_id}"
    "--DataCategory"        : "${each.key}"
    "--OriginDB"            : "${var.dl_glue_job_raw_to_prepared.origin_db}"
  }

  tags = var.tags
}

resource "aws_s3_bucket_object" "scripts_raw_to_prepared" {
  
  for_each = toset(var.dl_s3_prefixes)
  bucket     = module.dl_s3_internal.s3_bucket_id
  key        = "${var.dl_glue_job_raw_to_prepared.scripts_folder}/${var.dl_glue_job_raw_to_prepared.name}.py"
  content    = file("scripts/glue_jobs/${var.dl_glue_job_raw_to_prepared.name}.py")
  kms_key_id = module.dl_kms.key_arn

}
    
resource "aws_kms_key" "cloudwatch_log" {
  description = "KMS key for CloudWatch log encryption"
  is_enabled  = true
} 
       
resource "aws_s3_bucket_acl" "this" {
     
  bucket = var.dl_s3_internal_bucket_name
  acl    = var.acl
  }
    
# Define the AWS Glue security configuration resource for S3 encryption and decryption
       
resource "aws_glue_security_configuration" "s3_encrypt_decrypt" {    
  name = "s3_encrypt_decrypt"
     
  lifecycle {
  ignore_changes = all
  }

  encryption_configuration {
    s3_encryption {
      s3_encryption_mode = "SSE-S3"
    }

    cloudwatch_encryption {
      cloudwatch_encryption_mode = "SSE-KMS"
      kms_key_arn                = aws_kms_key.cloudwatch_log.arn
    }

    job_bookmarks_encryption {
      job_bookmarks_encryption_mode = "DISABLED"
    }
  }
}
    
module "dl_s3_prepared" {
  source = "terraform-aws-modules/s3-bucket/aws"
}
 
module "dl_s3_internal" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.13.0"
  tags   = var.tags

  acl = "private"

  force_destroy = true
  lifecycle_rule = var.dl_s3_internal_lifecycle_rule
  #lifecycle_rule = local.dl_s3_internal_lifecycle_rule
}
      
locals {
  dl_s3_internal_lifecycle_rule = [
    {
      id      = "glacier_archive_rule"
      prefix  = "archive/"
      status  = "Disabled"
      archive = {
        days            = "60"
        glacier_job_tier = "Standard"
      }
    },
  ]
}
