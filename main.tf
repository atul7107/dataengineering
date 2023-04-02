module "dl_kms" {
  source = "terraform-aws-modules/kms/aws"
}
  
resource "aws_s3_bucket" "this" {
  bucket = var.dl_s3_internal_bucket_name

  for_each = length(keys(var.server_side_encryption_configuration)) == 0 ? [] : [var.server_side_encryption_configuration.default]

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = each.value.rule.apply_server_side_encryption_by_default.sse_algorithm
      }
    }
  }
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
