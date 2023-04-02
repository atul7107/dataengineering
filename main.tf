module "dl_kms" {
  source = "terraform-aws-modules/kms/aws"
}

resource "aws_s3_bucket" "this" {
  # ... other configurations ...
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  rule {
    dynamic "lifecycle_rule" {
      for_each = var.dl_s3_raw.lifecycle_rule
      content {
        id      = lifecycle_rule.value.id
        status  = lifecycle_rule.value.enabled ? "Enabled" : "Disabled"

        dynamic "transition" {
          for_each = lifecycle_rule.value.transition
          content {
            days          = transition.value.days
            storage_class = transition.value.storage_class
          }
        }

        dynamic "expiration" {
          for_each = lifecycle_rule.value.expiration
          content {
            days = expiration.value.days
          }
        }
      }
    }
  }
  bucket = aws_s3_bucket.this.id
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
