module "dl_kms" {
  source = "terraform-aws-modules/kms/aws"
}

resource "aws_s3_bucket" "this" {
  bucket = "dataengineeringrawglabdev"
}
  
#resource "aws_s3_bucket" "this" {
 # }

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = { for rule in var.dl_s3_raw.lifecycle_rule : rule.id => rule }
    bucket = aws_s3_bucket.this.id
  
  rule {
    id      = each.value.id
    status  = each.value.enabled ? "Enabled" : "Disabled"

    dynamic "transition" {
      for_each = each.value.transition
      content {
        days          = transition.value.days
        storage_class = transition.value.storage_class
      }
    }

    dynamic "expiration" {
      for_each = each.value.expiration
      content {
        days = expiration.value.days
      }
    }
  }
}

# Define the AWS IAM role resource for Glue jobs
  
data "aws_iam_role" "existing_glue_jobs_role" {
  name = "glue-jobs-role"
}
  
resource "aws_iam_role" "glue_jobs" {
 count = length(data.aws_iam_role.existing_glue_jobs_role.*.arn) > 0 ? 0 : 1
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
