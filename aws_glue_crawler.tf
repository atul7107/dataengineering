resource "aws_glue_crawler" "crawler" {
  for_each = {
    for v in local.zone_prefix_map : "${v.zone}:${v.s3_prefix}" => v
  }

  database_name = aws_glue_catalog_database.data["${each.value.zone}"].name
  name          = "crawler_${each.value.zone}_${each.value.s3_prefix}"
  table_prefix  = "${each.value.s3_prefix}_"
  role          = length(data.aws_iam_role.existing_role.*.arn) > 0 ? data.aws_iam_role.existing_role.arn : aws_iam_role.dl_glue_crawler_role[0].arn
  tags          = var.tags

  s3_target {
    path = format(
      "s3://%s-%s-%s-${each.value.zone}-%s/${each.value.s3_prefix}/",
      var.tags.region,
      var.tags.company,
      var.tags.project,
      var.tags.environment,
    )
  }

  configuration = <<EOF
  {
   "Version": 1.0,
   "CrawlerOutput": {
      "Tables": { "AddOrUpdateBehavior": "MergeNewColumns" }
   }
  }
  EOF
}

resource "aws_glue_catalog_database" "data" {
  for_each = toset(var.region_availability_zones)
  name = "${var.dl_glue_raw_db}_${each.key}"

  lifecycle {
    ignore_changes = [
      name,
    ]
  }
}

data "aws_iam_role" "existing_role" {
  name  = "dl_glue_crawler_role"
}

resource "aws_iam_role" "dl_glue_crawler_role" {
  count = length(data.aws_iam_role.existing_role.*.arn) > 0 ? 0 : 1

  name = "dl_glue_crawler_role"

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
