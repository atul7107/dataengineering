resource "aws_glue_crawler" "crawler" {

  for_each = {
      for v in local.zone_prefix_map : "${v.zone}:${v.s3_prefix}" => v
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
