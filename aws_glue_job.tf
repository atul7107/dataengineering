resource "aws_glue_job" "raw_to_prepared" {
  
  module "dl_kms" {
  source = "terraform-aws-modules/kms/aws"
}
  
  module "dl_s3_internal" {
  source = "terraform-aws-modules/s3-bucket/aws"
  tags   = var.tags
}  
    
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
  #kms_key_id = module.dl_kms.kms_arn

}
    
#Define the AWS Glue security configuration resource for S3 encryption and decryption
resource "aws_glue_security_configuration" "s3_encrypt_decrypt" {
  name                         = "s3_encrypt_decrypt" 
  encryption_configuration = {
  s3_encryption = {
  s3_encryption_mode = "SSE-S3"
    #kms_master_key_id = module.dl_kms.kms_arn
   }
  }   
  cloudwatch_encryption = {
    cloudwatch_encryption_mode = "SSE-KMS"
    kms_encryption_type = "KMS"
  }
}
 
module "dl_s3_internal" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.13.0"
  tags   = var.tags

  acl = "private"

  force_destroy = true

  server_side_encryption_configuration = [
    {
      rule = {
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "AES256"
        }
      }
    }
  ]

  lifecycle_rule = [
    {
      id      = "glacier_archive_rule"
      prefix  = "archive/"
      status  = "Enabled"
      archive = {
        days            = "60"
        glacier_job_tier = "Standard"
      }
    },
  ]
}
