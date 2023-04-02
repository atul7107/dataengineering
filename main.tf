module "dl_kms" {
  source = "terraform-aws-modules/kms/aws"
}

resource "aws_s3_bucket" "this" {
  # ... other configurations ...
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = { for rule in var.dl_s3_raw.lifecycle_rule : rule.id => rule }
  
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
