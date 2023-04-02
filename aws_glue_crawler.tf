resource "aws_glue_crawler" "crawler" {

  for_each = {
      for v in local.zone_prefix_map : "${v.zone}:${v.s3_prefix}" => v
  locals {
  zone_prefix_map = [
    {
      zone       = "raw"
      s3_prefix  = var.dl_s3_raw_prefix
    },
    {
      zone       = "prepared"
      s3_prefix  = var.dl_s3_prepared_prefix
    },
    {
      zone       = "curated"
      s3_prefix  = var.dl_s3_curated_prefix
    }
  ]
}
  }

  database_name = aws_glue_catalog_database.data["${each.value.zone}"].name
  name          = "crawler_${each.value.zone}_${each.value.s3_prefix}"
  table_prefix  = "${each.value.s3_prefix}_"
  role          = aws_iam_role.dl_glue_crawler_role.arn
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
  for_each = {
    for zone in var.dl_zones : zone => {
      name = "${var.dl_catalog_db.name}_${zone}"
      description = "${var.dl_catalog_db.description} ${upper(zone)} zone"
    }
  }

  name        = each.value.name
  description = each.value.description
}
    
resource "aws_iam_role" "dl_glue_crawler_role" {
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

