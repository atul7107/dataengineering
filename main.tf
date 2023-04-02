module "dl_kms" {
  source = "terraform-aws-modules/kms/aws"
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
